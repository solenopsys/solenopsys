


function startRecord(timeout:number, canvas:HTMLCanvasElement) {
    const stream = canvas.captureStream(30); 
    const recorder = new MediaRecorder(stream);
    const chunks:Blob[] = [];

    recorder.ondataavailable = (event) => {
        chunks.push(event.data);
    };

    recorder.onstop = () => {
        const blob = new Blob(chunks, { type: 'video/webm' });
        const url = URL.createObjectURL(blob);

        // Создать ссылку для скачивания видео
        const a = document.createElement('a');
        a.href = url;
        a.download = 'webgl-video.webm';
        a.click();
        URL.revokeObjectURL(url);
    };

    recorder.start();

    setTimeout(() => recorder.stop(), timeout);
}


function main() {
    const canvas = document.createElement('canvas');
    document.body.appendChild(canvas);
    const gl = canvas.getContext('webgl');
    
    startRecord(10000, canvas);
}
