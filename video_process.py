import time
import datetime
import numpy as np
import imutils
import aiohttp
import asyncio
import cv2
import time
from math import ceil
from scipy.spatial.distance import euclidean
from tracking import detect_human
from util import rect_distance, progress, kinetic_energy
from colors import RGB_COLORS
from config import SHOW_DETECT, DATA_RECORD, RE_CHECK, RE_START_TIME, RE_END_TIME, SD_CHECK, SHOW_VIOLATION_COUNT, SHOW_TRACKING_ID, SOCIAL_DISTANCE,\
	SHOW_PROCESSING_OUTPUT, YOLO_CONFIG, VIDEO_CONFIG, DATA_RECORD_RATE, ABNORMAL_CHECK, ABNORMAL_ENERGY, ABNORMAL_THRESH, ABNORMAL_MIN_PEOPLE
from deep_sort import nn_matching
from deep_sort.detection import Detection
from deep_sort.tracker import Tracker
from deep_sort import generate_detections as gdet
import requests
import cv2
import numpy as np
IS_CAM = VIDEO_CONFIG["IS_CAM"]
HIGH_CAM = VIDEO_CONFIG["HIGH_CAM"]

'''def _record_movement_data(movement_data_writer, movement):
	track_id = movement.track_id 
	entry_time = movement.entry 
	exit_time = movement.exit			
	positions = movement.positions
	# write in a txt file the positions object to see whats isnsight 
 	# since python 3.6 does not support debugging
	positions = np.array(positions).flatten()
	positions = list(positions)
	data = [track_id] + [entry_time] + [exit_time] + positions
	movement_data_writer.writerow(data)'''
def _record_movement_data(movement_data_writer, movement):
    track_id = movement.track_id 
    entry_time = movement.entry 
    exit_time = movement.exit			
    positions = movement.positions

    # Write the positions object to a text file for inspection
    with open('positions_debug.txt', 'a') as f:
        f.write(f"Track ID: {track_id} - Entry: {entry_time} - Exit: {exit_time}\n")
        f.write(f"Positions: {positions}\n\n")

    # Flatten positions using numpy and convert to list
    positions = np.array(positions).flatten()
    positions = list(positions)

    # Prepare the data for CSV writing
    data = [track_id, entry_time, exit_time] + positions
    movement_data_writer.writerow(data)

def _record_crowd_data(time, human_count, violate_count, restricted_entry, abnormal_activity, crowd_data_writer):
	data = [time, human_count, violate_count, int(restricted_entry), int(abnormal_activity)]
	crowd_data_writer.writerow(data)

def _end_video(tracker, frame_count, movement_data_writer):
	for t in tracker.tracks:
		if t.is_confirmed():
			t.exit = frame_count
			_record_movement_data(movement_data_writer, t)

async def send_frame(session, url, frame):

	#gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
	resized_frame = cv2.resize(frame, (640, 480))
	_, img_encoded = cv2.imencode('.jpg', resized_frame, [int(cv2.IMWRITE_JPEG_QUALITY), 10])
	async with session.post(url, data=img_encoded.tobytes()) as response:
		print(await response.text())

def create_red_gradient(width, height, horizontal=True):
    """Create a linear red gradient image."""
    if horizontal:
        # Horizontal gradient
        gradient = np.zeros((height, width, 3), dtype=np.uint8)
        gradient[:, :, 2] = np.tile(np.linspace(0, 255, width, dtype=np.uint8), (height, 1))
    else:
        # Vertical gradient
        gradient = np.zeros((width, height, 3), dtype=np.uint8)
        gradient[:, :, 2] = np.tile(np.linspace(0, 255, height, dtype=np.uint8), (width, 1))
        gradient = np.transpose(gradient, (1, 0, 2))  # transpose to switch to vertical
    return gradient


def apply_red_gradient_border(frame, border_size=20):
    height, width = frame.shape[:2]
    # Create red gradient images for all sides
    top_gradient = create_red_gradient(width, border_size, horizontal=True)
    bottom_gradient = cv2.flip(top_gradient, 0)  # Flip top gradient to get bottom gradient
    left_gradient = create_red_gradient(border_size, height, horizontal=False)
    right_gradient = cv2.flip(left_gradient, 1)  # Flip left gradient to get right gradient

    # Apply red gradients to the borders
    frame[:border_size, :] = cv2.addWeighted(frame[:border_size, :], 0.5, top_gradient, 0.5, 0)
    frame[-border_size:, :] = cv2.addWeighted(frame[-border_size:, :], 0.5, bottom_gradient, 0.5, 0)
    frame[:, :border_size] = cv2.addWeighted(frame[:, :border_size], 0.5, left_gradient, 0.5, 0)
    frame[:, -border_size:] = cv2.addWeighted(frame[:, -border_size:], 0.5, right_gradient, 0.5, 0)

    return frame

		

async def video_process(cap, frame_size, net, ln, encoder, tracker, movement_data_writer, crowd_data_writer):
	def _calculate_FPS():
		t1 = time.time() - t0
		VID_FPS = frame_count / t1

	if IS_CAM:
		VID_FPS = None
		DATA_RECORD_FRAME = 1
		TIME_STEP = 1
		t0 = time.time()
	else:
		VID_FPS = cap.get(cv2.CAP_PROP_FPS)
		DATA_RECORD_FRAME = int(VID_FPS / DATA_RECORD_RATE)
		TIME_STEP = DATA_RECORD_FRAME/VID_FPS

	frame_count = 0
	display_frame_count = 0
	re_warning_timeout = 0
	sd_warning_timeout = 0
	ab_warning_timeout = 0

	RE = False
	ABNORMAL = False
	async with aiohttp.ClientSession() as session:
		loop = asyncio.get_event_loop()
		while True:
			(ret, frame) = cap.read()

			# Stop the loop when video ends
			if not ret:
				_end_video(tracker, frame_count, movement_data_writer)
				if not VID_FPS:
					_calculate_FPS()
				break

			# Update frame count
			if frame_count > 1000000:
				if not VID_FPS:
					_calculate_FPS()
				frame_count = 0
				display_frame_count = 0
			frame_count += 1
			
			# Skip frames according to given rate
			if frame_count % DATA_RECORD_FRAME != 0:
				continue

			display_frame_count += 1

			# Resize Frame to given size
			frame = imutils.resize(frame, width=frame_size)

			# Get current time
			current_datetime = datetime.datetime.now()

			# Run detection algorithm
			if IS_CAM:
				record_time = current_datetime
			else:
				record_time = frame_count
			
			# Run tracking algorithm
			[humans_detected, expired] = detect_human(net, ln, frame, encoder, tracker, record_time)

			# Record movement data
			for movement in expired:

				_record_movement_data(movement_data_writer, movement)
			
			# Check for restricted entry
			if RE_CHECK:
				RE = False
				if (current_datetime.time() > RE_START_TIME) and (current_datetime.time() < RE_END_TIME) :
					if len(humans_detected) > 0:
						RE = True
				
			# Initiate video process loop
			if SHOW_PROCESSING_OUTPUT or SHOW_DETECT or SD_CHECK or RE_CHECK or ABNORMAL_CHECK:
				# Initialize set for violate so an individual will be recorded only once
				violate_set = set()
				# Initialize list to record violation count for each individual detected
				violate_count = np.zeros(len(humans_detected))

				# Initialize list to record id of individual with abnormal energy level
				abnormal_individual = []
				ABNORMAL = False
				for i, track in enumerate(humans_detected):
					# Get object bounding box
					[x, y, w, h] = list(map(int, track.to_tlbr().tolist()))
					# Get object centroid
					[cx, cy] = list(map(int, track.positions[-1]))
					# Get object id
					idx = track.track_id
					# Check for social distance violation
					if SD_CHECK:
						if len(humans_detected) >= 2:
							# Check the distance between current loop object with the rest of the object in the list
							for j, track_2 in enumerate(humans_detected[i+1:], start=i+1):
								if HIGH_CAM:
									[cx_2, cy_2] = list(map(int, track_2.positions[-1]))
									distance = euclidean((cx, cy), (cx_2, cy_2))
								else:
									[x_2, y_2, w_2, h_2] = list(map(int, track_2.to_tlbr().tolist()))
									distance = rect_distance((x, y, w, h), (x_2, y_2, w_2, h_2))
								if distance < SOCIAL_DISTANCE:
									# Distance between detection less than minimum social distance 
									violate_set.add(i)
									violate_count[i] += 1
									violate_set.add(j)
									violate_count[j] += 1

					# Compute energy level for each detection
					if ABNORMAL_CHECK:
						ke = kinetic_energy(track.positions[-1], track.positions[-2], TIME_STEP)
						if ke > ABNORMAL_ENERGY:
							abnormal_individual.append(track.track_id)

					# If restrited entry is on, draw red boxes around each detection
					if RE:
						cv2.rectangle(frame, (x + 5 , y + 5 ), (w - 5, h - 5), RGB_COLORS["red"], 5)

					# Draw yellow boxes for detection with social distance violation, green boxes for no violation
					# Place a number of violation count on top of the box
					if i in violate_set:
						cv2.rectangle(frame, (x, y), (w, h), RGB_COLORS["yellow"], 2)
						if SHOW_VIOLATION_COUNT:
							cv2.putText(frame, str(int(violate_count[i])), (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.8, RGB_COLORS["yellow"], 2)
					elif SHOW_DETECT and not RE:
						cv2.rectangle(frame, (x, y), (w, h), RGB_COLORS["green"], 2)
						if SHOW_VIOLATION_COUNT:
							cv2.putText(frame, str(int(violate_count[i])), (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.8, RGB_COLORS["green"], 2)
					
					if SHOW_TRACKING_ID:
						cv2.putText(frame, str(int(idx)), (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.8, RGB_COLORS["green"], 2)
				
				# Check for overall abnormal level, trigger notification if exceeds threshold
				if len(humans_detected)  > ABNORMAL_MIN_PEOPLE:
					if len(abnormal_individual) / len(humans_detected) > ABNORMAL_THRESH:
						ABNORMAL = True

			# Place violation count on frames
			if SD_CHECK:
				# Warning stays on screen for 10 frames
				if (len(violate_set) > 0):
					sd_warning_timeout = 10
				else: 
					sd_warning_timeout -= 1
				# Display violation warning and count on screen
				if sd_warning_timeout > 0:
					text = "Violation count: {}".format(len(violate_set))
					cv2.putText(frame, text, (200, frame.shape[0] - 30),
						cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 3)

			# Place restricted entry warning
			if RE_CHECK:
				# Warning stays on screen for 10 frames
				if RE:
					re_warning_timeout = 10
				else: 
					re_warning_timeout -= 1
				# Display restricted entry warning and count on screen
				if re_warning_timeout > 0:
					if display_frame_count % 3 != 0 :
						cv2.putText(frame, "RESTRICTED ENTRY", (200, 100),
							cv2.FONT_HERSHEY_SIMPLEX, 1, RGB_COLORS["red"], 3)

			# Place abnormal activity warning
			if ABNORMAL_CHECK:
				if ABNORMAL:
					# Warning stays on screen for 10 frames
					ab_warning_timeout = 10
					# Draw blue boxes over the the abnormally behave detection if abnormal activity detected
					for track in humans_detected:
						if track.track_id in abnormal_individual:
							[x, y, w, h] = list(map(int, track.to_tlbr().tolist()))
							cv2.rectangle(frame, (x , y ), (w, h), RGB_COLORS["blue"], 5)
				else:
					ab_warning_timeout -= 1
				if ab_warning_timeout > 0:
					if display_frame_count % 3 != 0:
						cv2.putText(frame, "ABNORMAL ACTIVITY", (130, 250),
							cv2.FONT_HERSHEY_SIMPLEX, 1.5, RGB_COLORS["blue"], 5)
						thickness = 30
						height, width = frame.shape[:2]
						frame = apply_red_gradient_border(frame, border_size=50)

			# Display crowd count on screen
			if SHOW_DETECT:
				text = "Crowd count: {}".format(len(humans_detected))
				cv2.putText(frame, text, (10, 30),
					cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 3)

			# Display current time on screen
			# current_date = str(current_datetime.strftime("%b-%d-%Y"))
			# current_time = str(current_datetime.strftime("%I:%M:%S %p"))
			# cv2.putText(frame, (current_date), (500, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 0), 3)
			# cv2.putText(frame, (current_time), (500, 60), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 0), 3)
			
			# Record crowd data to file
			if DATA_RECORD:
				_record_crowd_data(record_time, len(humans_detected), len(violate_set), RE, ABNORMAL, crowd_data_writer)
			

			# Display video output or processing indicator
			if SHOW_PROCESSING_OUTPUT:
				cv2.imshow("Processed Output", frame)
				# Convert the image/frame to jpg
				_, img_encoded = cv2.imencode('.jpg', frame)
			else:
				progress(display_frame_count)

			# turn frame into gray
			
			loop.create_task(await send_frame(session, 'https://backend-aeh7hwqzuq-oe.a.run.app/video_feed', frame))
			
			

	

			# Press 'Q' to stop the video display
			if cv2.waitKey(1) & 0xFF == ord('q'):
				# Record the movement when video ends
				_end_video(tracker, frame_count, movement_data_writer)
				# Compute the processing speed
				if not VID_FPS:
					_calculate_FPS()
				break
		

	
	cv2.destroyAllWindows()
	return VID_FPS
