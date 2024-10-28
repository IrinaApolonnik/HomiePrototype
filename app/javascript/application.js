// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

function cardsAppear() {
    const elements = document.querySelectorAll('.card');

    elements.forEach(element => {
        // Задержка для каждого элемента
        const delay = element.getAttribute('data-delay');
        element.style.animationDelay = delay;
        
        // Добавляем класс анимации с задержкой
        element.classList.add('slideUpAppear');
    });

}


document.addEventListener("DOMContentLoaded", () => {
    cardsAppear();
});