import anime from 'animejs';

export function drawCircles() {
    const container = document.getElementById("container");

    const radius = 100; // Радиус окружности
    // Параметры круга
    const numCircles = 20; // Количество новых кружков

    // Создание новых кружков
    for (let i = 0; i < numCircles; i++) {
      
        const circle = document.createElement('div');
        circle.classList.add('circle');
        container?.appendChild(circle);
    }

    // Получаем все созданные кружки
    const circles = document.querySelectorAll('.circle:not(#center-circle)');

  
// Create lines connecting each pair of circles
for (let i = 0; i < numCircles; i++) {
    for (let j = i + 1; j < numCircles; j++) {
        const line = document.createElementNS("http://www.w3.org/2000/svg", "line");
        line.setAttribute('x1', '0');
        line.setAttribute('y1', '0');
        line.setAttribute('x2', '0');
        line.setAttribute('y2', '0');
        line.setAttribute('stroke', 'white');
        line.setAttribute('stroke-dasharray', '5,5'); // Makes the line dashed
        container?.appendChild(line);
    }
}

const lines = document.querySelectorAll('.line-container line');

// Анимация с помощью Anime.js
anime.timeline({
    easing: 'easeOutExpo',
    duration: 1000
})
    .add({
        opacity: [0, 1], // Появление новых кружков
        scale: [0, 1], // Увеличение размера
        targets: circles,
        translateX: function (el, i) {
            return radius * Math.cos(2 * Math.PI * i / numCircles) + 320; // Расположение по окружности по оси X
        },
        translateY: function (el, i) {
            return radius * Math.sin(2 * Math.PI * i / numCircles) + 160; // Расположение по окружности по оси Y
        },
        delay: anime.stagger(100), // Пауза перед каждым кружком
    })
    .add({
        targets: lines,
        x1: function (el, i) {
            const circleIndex = Math.floor(i / (numCircles - 1));
            return radius * Math.cos(2 * Math.PI * circleIndex / numCircles) + 320;
        },
        y1: function (el, i) {
            const circleIndex = Math.floor(i / (numCircles - 1));
            return radius * Math.sin(2 * Math.PI * circleIndex / numCircles) + 160;
        },
        x2: function (el, i) {
            const pairIndex = i % (numCircles - 1) + 1;
            return radius * Math.cos(2 * Math.PI * pairIndex / numCircles) + 320;
        },
        y2: function (el, i) {
            const pairIndex = i % (numCircles - 1) + 1;
            return radius * Math.sin(2 * Math.PI * pairIndex / numCircles) + 160;
        },
        duration: 800,
        easing: 'easeOutQuad',
        delay: anime.stagger(50)
    });

}