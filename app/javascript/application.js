// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

// Функция для анимации появления карточек
function selectedTag() {
    const tagButtons = document.querySelectorAll(".Q_tagBtn");
    const hiddenInput = document.getElementById("post_tag_list");
  
    if (!tagButtons.length || !hiddenInput) {
      console.error("Tag buttons or hidden input field not found.");
      return;
    }
  
    tagButtons.forEach((button) => {
      button.addEventListener("click", () => {
        const isSelected = button.getAttribute("data-selected") === "true";
        button.setAttribute("data-selected", !isSelected);
        button.classList.toggle("selected", !isSelected); // Добавляем/убираем класс "selected"
  
        // Обновляем скрытое поле
        const selectedTags = Array.from(tagButtons)
          .filter((btn) => btn.getAttribute("data-selected") === "true")
          .map((btn) => btn.getAttribute("data-tag"));
        hiddenInput.value = selectedTags.join(",");
      });
    });
  }
// Функция тегов
function cardsAppear() {
    const elements = document.querySelectorAll(".card");

    elements.forEach((element) => {
        // Проверяем наличие атрибута data-delay
        const delay = element.getAttribute("data-delay") || "0s";
        element.style.animationDelay = delay;

        // Добавляем класс анимации с задержкой
        element.classList.add("slideUpAppear");
    });
}
// Загрузка изображения (аватара или поста)
function addImage() {
    const setupImageUpload = (fileInputId, previewClass, imgClass, placeholderClass) => {
      const fileInput = document.getElementById(fileInputId);
      const preview = document.querySelector(`.${previewClass}`);
      const image = preview?.querySelector(`.${imgClass}`);
      const placeholder = preview?.querySelector(`.${placeholderClass}`);
  
      if (fileInput) {
        fileInput.addEventListener("change", (event) => {
          const file = event.target.files[0];
  
          if (file) {
            const reader = new FileReader();
  
            reader.onload = (e) => {
              if (image) image.src = e.target.result; // Устанавливаем выбранное изображение
              image?.classList.remove("hidden"); // Показываем изображение
              placeholder?.classList.add("hidden"); // Скрываем плюсик
            };
  
            reader.readAsDataURL(file); // Читаем файл как URL
          }
        });
      }
    };
  
    // Для аватарки
    setupImageUpload(
      "avatar_upload", 
      "Q_avatarPreview", 
      "Q_avatarImgUpload", 
      "placeholder" 
    );
    setupImageUpload(
        "edit_avatar_image_upload", 
        "Q_editAvatarPreview", 
        "Q_editAvatarImgUpload",
        "placeholder" 
    );
  
    // Для изображения поста
    setupImageUpload(
      "post_image_upload", 
      "Q_postImagePreview", 
      "Q_postImgUpload", 
      "placeholder" 
    );

    
  }

// Выпадающее меню
function dropdownMenu() {
    const dropdownButton = document.querySelector('.Q_dropdownBtn');
    const dropdownMenu = document.querySelector('.W_dropdownProfileMenu');

    // Добавляем обработчик клика на кнопку
    dropdownButton.addEventListener('click', () => {
        dropdownMenu.classList.toggle('active');
    });

    // Закрытие меню при клике вне его
    document.addEventListener('click', (event) => {
        if (!dropdownMenu.contains(event.target) && !dropdownButton.contains(event.target)) {
            dropdownMenu.classList.remove('active');
        }
    });
}
// Обработка первой секции регистрации
function regSection() {
    const registrationFormSelector = ".S_firstRegistrationStep form";

    toggleSubmitButtonState(registrationFormSelector); // Включаем логику управления кнопкой

    const registrationForm = document.querySelector(registrationFormSelector);

    if (registrationForm) {
        const submitButton = registrationForm.querySelector("input[type=submit]");

        registrationForm.addEventListener("submit", async (event) => {
            event.preventDefault(); // Предотвращаем стандартное поведение отправки
            const formData = new FormData(registrationForm);

            submitButton.disabled = true; // Блокируем кнопку во время отправки

            try {
                const response = await fetch(registrationForm.action, {
                    method: "POST",
                    body: formData,
                    headers: {
                        "Accept": "application/json",
                        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                    },
                });

                if (response.ok) {
                    document.querySelector(".S_secondRegistrationStep").classList.add("slide-in");
                }
            } finally {
                submitButton.disabled = false; // Разблокируем кнопку после завершения
            }
        });
    }
}

// Обработка второй секции регистрации (профиля)
function profileSection() {
    const profileFormSelector = ".S_secondRegistrationStep form";

    toggleSubmitButtonState(profileFormSelector); // Включаем логику управления кнопкой

    const profileForm = document.querySelector(profileFormSelector);

    if (profileForm) {
        profileForm.addEventListener("submit", async (event) => {
            event.preventDefault();
            const formData = new FormData(profileForm);
            const submitButton = profileForm.querySelector("button[type=submit], input[type=submit]");

            if (submitButton) submitButton.disabled = true;

            try {
                const response = await fetch(profileForm.action, {
                    method: "POST",
                    body: formData,
                    headers: {
                        "Accept": "text/html",
                        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                    },
                });

                if (response.ok) {
                    window.location.href = "/";
                }
            } finally {
                if (submitButton) submitButton.disabled = false;
            }
        });
    }
}

function toggleSubmitButtonState(formSelector) {
    const form = document.querySelector(formSelector);

    if (!form) return;

    const submitButton = form.querySelector("input[type=submit], button[type=submit]");
    if (!submitButton) return;

    // Функция проверки валидности формы
    function checkFormValidity() {
        const isValid = Array.from(form.querySelectorAll("input")).every((input) => input.value.trim() !== "");
        submitButton.disabled = !isValid;
        submitButton.classList.toggle("disabled", !isValid);
    }

    // Слушаем изменения в форме
    form.addEventListener("input", checkFormValidity);

    // Изначальная проверка при загрузке
    checkFormValidity();
}
function toggleActionButtonsState(formSelector, actionsSelector) {
    const form = document.querySelector(formSelector);
    const actionButtons = document.querySelector(actionsSelector);

    if (!form || !actionButtons) return;

    // Функция проверки изменений в форме
    function checkFormChanges() {
        const isChanged = Array.from(form.querySelectorAll("input, textarea, select")).some((input) => {
            if (input.type === "file") {
                return input.files.length > 0; // Проверяем, загружен ли файл
            }
            return input.defaultValue !== input.value.trim(); // Проверяем текстовые поля
        });

        // Показываем или скрываем кнопки в зависимости от изменений
        actionButtons.classList.toggle("hidden", !isChanged);
    }

    // Слушаем изменения в форме
    form.addEventListener("input", checkFormChanges);

    // Изначальная проверка при загрузке
    checkFormChanges();
}

// Пример использования:
document.addEventListener("DOMContentLoaded", () => {
    toggleActionButtonsState("#edit_profile_form", ".C_editProfileActions");
});



// Выпадающее меню
function profilePostsToggle() {
    const userPostsBtn = document.getElementById("userPostsBtn");
    const likedPostsBtn = document.getElementById("likedPostsBtn");
    const userPostsFeed = document.getElementById("userPostsFeed");
    const likedPostsFeed = document.getElementById("likedPostsFeed");
  
    function toggleFeeds(activeBtn, inactiveBtn, activeFeed, inactiveFeed) {
      activeBtn.classList.add("active");
      inactiveBtn.classList.remove("active");
      activeFeed.classList.add("active");
      activeFeed.classList.remove("hidden");
      inactiveFeed.classList.remove("active");
      inactiveFeed.classList.add("hidden");
    }
  
    userPostsBtn.addEventListener("click", () => {
      toggleFeeds(userPostsBtn, likedPostsBtn, userPostsFeed, likedPostsFeed);
    });
  
    likedPostsBtn.addEventListener("click", () => {
      toggleFeeds(likedPostsBtn, userPostsBtn, likedPostsFeed, userPostsFeed);
    });
}


// Функция для управления состоянием лайков
function likeStates() {
    document.querySelectorAll(".Q_likeBtn").forEach((button) => {
        button.addEventListener("click", async (event) => {
            event.preventDefault();

            // Получаем элементы
            const likesCountElement = button.parentElement.querySelector(".Q_likesCount");
            const icon = button.querySelector("img");

            // Проверяем, что элементы существуют
            if (!likesCountElement || !icon) {
                console.error("Не удалось найти элементы лайка.");
                return;
            }

            // Читаем данные
            const likeableId = button.dataset.id;
            const isLiked = button.dataset.liked === "true";
            const likeableType = button.dataset.type; // Добавляем поддержку типа (Post или Comment)

            if (!likeableId || !likeableType) {
                console.error("Отсутствуют необходимые данные для лайка.");
                return;
            }

            // Обновляем визуально локально
            let likesCount = parseInt(likesCountElement.dataset.likes, 10);

            if (isLiked) {
                likesCount -= 1;
                icon.src = "/assets/heartIcon_b.svg"; // Меняем на outline
            } else {
                likesCount += 1;
                icon.src = "/assets/heartIcon_o.svg"; // Меняем на filled
            }

            // Добавляем класс анимации
            button.classList.add("likeAnimation");
            likesCountElement.classList.add("likeAnimation");

            // Убираем класс анимации после завершения
            setTimeout(() => {
                button.classList.remove("likeAnimation");
                likesCountElement.classList.remove("likeAnimation");
            }, 300);

            // Обновляем текст и атрибуты
            likesCountElement.textContent = likesCount;
            likesCountElement.dataset.likes = likesCount;
            button.dataset.liked = (!isLiked).toString();

            // Отправляем запрос на сервер
            try {
                const response = await fetch(`/like/toggle?type=${likeableType}&id=${likeableId}`, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                    },
                });

                if (!response.ok) {
                    throw new Error("Ошибка при обновлении лайка.");
                }

                const data = await response.json();

                // Синхронизируем данные с сервером
                likesCountElement.textContent = data.likes_count;
                likesCountElement.dataset.likes = data.likes_count;
                button.dataset.liked = data.liked.toString();
            } catch (error) {
                console.error(error);

                // Откатываем изменения при ошибке
                if (isLiked) {
                    likesCount += 1;
                    icon.src = "/assets/heartIcon_o.svg";
                } else {
                    likesCount -= 1;
                    icon.src = "/assets/heartIcon_b.svg";
                }

                likesCountElement.textContent = likesCount;
                likesCountElement.dataset.likes = likesCount;
                button.dataset.liked = isLiked.toString();
            }
        });
    });
}

// Функция для анимации появления карточек
function popularPosts() {
    const cardsContainer = document.querySelector("[data-cards]");
    if (!cardsContainer) {
        console.log("Элемент для популярных постов отсутствует на этой странице.");
        return; // Прерываем выполнение, если контейнер отсутствует
    }

    const prevButton = document.querySelector("[data-prev]");
    const nextButton = document.querySelector("[data-next]");
    const cards = Array.from(cardsContainer.children); // Все карточки
    const cardsPerPage = 4; // Количество карточек на одной странице
    let currentPage = 0; // Текущая страница

    // Устанавливаем начальное состояние карточек
    function updateVisibleCards() {
        cards.forEach((card, index) => {
            const start = currentPage * cardsPerPage;
            const end = start + cardsPerPage;
            if (index >= start && index < end) {
                card.style.display = "block"; // Показываем карточку
            } else {
                card.style.display = "none"; // Скрываем карточку
            }
        });

        // Обновляем прозрачность кнопок
        updateButtonStates();
    }

    // Обновляем состояние кнопок
    function updateButtonStates() {
        prevButton.style.opacity = currentPage === 0 ? "0.5" : "1";
        nextButton.style.opacity = (currentPage + 1) * cardsPerPage >= cards.length ? "0.5" : "1";
    }

    // Обработчик для кнопки "Назад"
    prevButton.addEventListener("click", () => {
        if (currentPage > 0) {
            currentPage--;
            updateVisibleCards();
        }
    });

    // Обработчик для кнопки "Вперед"
    nextButton.addEventListener("click", () => {
        if ((currentPage + 1) * cardsPerPage < cards.length) {
            currentPage++;
            updateVisibleCards();
        }
    });

    // Инициализация
    updateVisibleCards();
}

// Инициализация функций
document.addEventListener("turbo:load", () => {
    if (document.querySelector("[data-cards]")) {
        popularPosts();
    }
    if (document.getElementById("userPostsFeed")) {
        profilePostsToggle();
    }
    if (document.querySelector('.Q_dropdownBtn')) {
        dropdownMenu();
    }

    selectedTag();

    cardsAppear();
    likeStates();


    regSection();
    profileSection();
    addImage();
    toggleSubmitButtonState(".S_firstRegistrationStep form");
    toggleSubmitButtonState(".S_secondRegistrationStep form");
    toggleActionButtonsState("#edit_profile_form", ".C_editProfileActions");
    
});
