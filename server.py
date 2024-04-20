from flask import Flask, Response, request, render_template
import cv2
import numpy as np

app = Flask(__name__)
frame_buffer = []

@app.route('/video_feed', methods=['POST', 'GET'])
def video_feed():
    if request.method == 'POST':
        # Handle frame reception
        nparr = np.frombuffer(request.data, np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        _, buffer = cv2.imencode('.jpg', frame)
        frame_buffer.append(buffer.tobytes())
        return 'Frame received', 200

    elif request.method == 'GET':
        # Serve frames to the client
        return Response(stream_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

def stream_frames():
    while True:
        while frame_buffer:
            frame = frame_buffer.pop(0)
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

@app.route('/')
def index():
    return render_template('index.html')  # HTML to show the video

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)