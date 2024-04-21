from flask import Flask, render_template, abort

app = Flask(__name__)

# Dictionary mapping video IDs to filenames
videos = {
    'video1': 'prison.mp4',
    'video2': 'soccer.MP4',
    'video3': 'running.MP4',
}

@app.route('/<video_id>')
def stream_video(video_id):
    video_file = videos.get(video_id)
    if not video_file:
        abort(404)  # Return a 404 not found error if the video does not exist
    return render_template('video.html', video_file=video_file)

if __name__ == "__main__":
    app.run(debug=True)
