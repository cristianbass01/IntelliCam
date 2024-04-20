from aiohttp import web
import cv2
import numpy as np
import asyncio



async def index(request):
    # Serve a simple HTML page that displays the video
    return web.Response(text="<html><body><img src='/video_feed' /></body></html>", content_type='text/html')

async def video_feed(request):
    response = web.StreamResponse(status=200, reason='OK', headers={'Content-Type': 'multipart/x-mixed-replace; boundary=frame'})
    await response.prepare(request)

    while True:
        frame = await request.app['frame_queue'].get()
        if frame is None:  # Use None as a signal to stop.
            break
        # Stream the frame
        await response.write(b'--frame\r\nContent-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
        request.app['frame_queue'].task_done()

    return response

async def handle_post(request):
    data = await request.read()
    nparr = np.frombuffer(data, np.uint8)
    frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    _, buffer = cv2.imencode('.jpg', frame)
    await request.app['frame_queue'].put(buffer.tobytes())
    return web.Response(text='Frame received', status=200)

async def start_background_tasks(app):
    app['frame_queue'] = asyncio.Queue()

async def cleanup_background_tasks(app):
    await app['frame_queue'].put(None)

app = web.Application()
app.on_startup.append(start_background_tasks)
app.on_cleanup.append(cleanup_background_tasks)
app.add_routes([web.get('/', index),
                web.get('/video_feed', video_feed),
                web.post('/video_feed', handle_post)])

if __name__ == '__main__':
    web.run_app(app, host='0.0.0.0', port=5000)
