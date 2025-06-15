// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "./masonry.pkgd.min.js";
import Rails from "@rails/ujs";
Rails.start();

function systemMessage() {
    const message = document.querySelector(".A_systemMessage, .systemMessage");

    if (message && message.textContent.trim() !== "") {
        message.classList.add("show"); 

        setTimeout(() => {
            message.classList.add("fade-out"); 

            // Удаляем элемент через 500ms после исчезновения
            setTimeout(() => message.remove(), 700);
        }, 3000);
    }
}

window.showFlashNotice = function(message) {
  const flash = document.createElement('div');
  flash.className = 'A_systemMessage';
  flash.innerHTML = `
    <img src="/assets/successNoticeIcon.svg">
    <h3>${message}</h3>
  `;
  document.body.appendChild(flash);
  systemMessage(); // запуск анимации и удаление
};

window.showFlashAlert = function(message) {
  const flash = document.createElement('div');
  flash.className = 'A_systemMessage systemMessage--error'; // если хочешь стилизовать ошибку отдельно
  flash.innerHTML = `
    <img src="/assets/images/crossicon_b.svg"> 
    <h3>${message}</h3>
  `;
  document.body.appendChild(flash);
  systemMessage();
};



function changeLayout() {
    const layoutButtons = document.querySelectorAll(".Q_changeFeedLayoutBtn");
    const postsFeed = document.getElementById("C_postsFeed");

    if (layoutButtons.length > 0 && postsFeed) {
        // Устанавливаем сетку по умолчанию (если в localStorage нет сохраненного значения)
        const savedLayout = localStorage.getItem("feedLayout") || "big";
        postsFeed.classList.add(savedLayout);

        // Устанавливаем правильный active на кнопке
        layoutButtons.forEach(button => {
            const isBigLayout = button.querySelector("img").getAttribute("src").includes("bigLayoutIcon");
            if ((savedLayout === "big" && isBigLayout) || (savedLayout === "compact" && !isBigLayout)) {
                button.classList.add("active");
            }
        });

        // Обработчик клика на кнопку смены лэйаута
        layoutButtons.forEach(button => {
            button.addEventListener("click", function () {
                // Убираем active у всех кнопок
                layoutButtons.forEach(btn => btn.classList.remove("active"));
                // Добавляем active текущей кнопке
                this.classList.add("active");

                // Проверяем, какая кнопка нажата и меняем класс у C_postsFeed
                let newLayout;
                if (this.querySelector("img").getAttribute("src").includes("bigLayoutIcon")) {
                    postsFeed.classList.remove("compact");
                    postsFeed.classList.add("big");
                    newLayout = "big";
                } else {
                    postsFeed.classList.remove("big");
                    postsFeed.classList.add("compact");
                    newLayout = "compact";
                }

                // Сохраняем выбор в localStorage
                localStorage.setItem("feedLayout", newLayout);
            });
        });
    }
}

function masonry() {
    const feed = document.querySelector("#C_postsFeed");

    if (!feed) return console.error("Masonry Error: #C_postsFeed не найден");

    function getGutterSize() {
        return Math.round(window.innerWidth * 0.015); // 1.5vw → px
    }

    function getColumnWidth() {
        const containerWidth = feed.clientWidth;
        const gutter = getGutterSize();
        
        if (feed.classList.contains("big")) {
            return (containerWidth - 2 * gutter) / 3; // 3 колонки
        } else {
            return (containerWidth - 4 * gutter) / 5; // 5 колонок
        }
    }

    function setPostSizes() {
        const posts = document.querySelectorAll(".O_post");
        const colWidth = getColumnWidth();
        
        posts.forEach(post => {
            post.style.width = `${colWidth}px`; // Теперь Masonry знает ширину постов
        });
    }

    console.log("Masonry: Init, container width:", feed.clientWidth);

    const msnry = new Masonry(feed, {
        itemSelector: ".O_post",
        columnWidth: getColumnWidth(),
        gutter: getGutterSize(),
        percentPosition: true,
    });

    function updateMasonry() {
        console.log("Masonry: Обновление...");
        setPostSizes(); // Устанавливаем правильную ширину
        msnry.options.columnWidth = getColumnWidth();
        msnry.options.gutter = getGutterSize();
        msnry.layout();
    }

    // Следим за сменой класса (big/compact)
    const observer = new MutationObserver(() => {
        console.log("Masonry: Изменился класс", feed.className);
        setTimeout(updateMasonry, 100);
    });

    observer.observe(feed, {
        attributes: true,
        attributeFilter: ["class"],
    });

    // Обновляем Masonry при изменении размера окна
    window.addEventListener("resize", updateMasonry);

    // Обновляем через 1 секунду после загрузки
    setTimeout(updateMasonry, 0);
}

function sort() {
    const sortOptions = document.querySelectorAll(".A_filterSort input[name='sort']");
    const applySortButton = document.querySelector(".A_showResult");
    const sortButton = document.querySelector(".Q_feedSortBtn");
    const sortOverlay = document.querySelector(".S_sort");
    const closeButton = document.querySelector(".Q_closeBtn");

    if (!sortOptions.length || !applySortButton || !closeButton || !sortButton || !sortOverlay) return;

    // Загружаем сохраненный выбор из localStorage
    const savedSort = localStorage.getItem("selectedSort") || "new";

    // Получаем текущую сортировку из URL (params[:sort])
    const url = new URL(window.location);
    const currentSort = url.searchParams.get("sort");

    // Если URL уже содержит нужную сортировку, ничего не меняем
    if (!currentSort && savedSort !== "new") {
        url.searchParams.set("sort", savedSort);
        
        // Используем pushState вместо replaceState, чтобы работала кнопка "Назад"
        window.history.pushState({}, "", url.toString()); 
    }

    // Устанавливаем checked у радио-кнопки, соответствующей savedSort
    sortOptions.forEach(option => {
        if (option.value === savedSort) {
            option.checked = true;
        }
    });

    // Обработчик кнопки "Показать результат"
    applySortButton.addEventListener("click", () => {
        const selectedSort = document.querySelector(".A_filterSort input[name='sort']:checked").value;

        // Сохраняем выбор пользователя в localStorage
        localStorage.setItem("selectedSort", selectedSort);

        // Если уже установлена эта сортировка, не перезагружаем
        if (selectedSort === currentSort) return;

        // Обновляем URL и перезагружаем посты через Turbo
        url.searchParams.set("sort", selectedSort);
        Turbo.visit(url.toString(), { action: "replace" });
    });

    // Открытие сортировки
    sortButton.addEventListener("click", () => {
        sortOverlay.style.display = "flex"; // Показываем фон
        setTimeout(() => {
            sortOverlay.classList.add("show"); // Затемняем фон
        }, 10);
    });

    // Закрытие сортировки
    function closeSort() {
        sortOverlay.classList.remove("show"); // Фон исчезает
        setTimeout(() => {
            sortOverlay.style.display = "none"; // Полностью скрываем
        }, 700);
    }

    closeButton.addEventListener("click", closeSort);

    // Закрытие при клике на фон
    sortOverlay.addEventListener("click", (event) => {
        if (event.target === sortOverlay) {
            closeSort();
        }
    });
}

function filter() {
  const filterOverlay = document.querySelector(".S_filter");
  const applyFilterButton = document.querySelector(".A_resultFilterBtn");
  const clearFilterButton = document.querySelector(".A_clearFilter");
  const filterButton = document.querySelector(".Q_feedFltrBtn");
  const closeButton = document.querySelector(".Q_closeFltrBtn");
  const checkboxes = document.querySelectorAll(".Q_checkbox");

  if (!filterOverlay || !applyFilterButton || !clearFilterButton || !filterButton || !closeButton || !checkboxes.length) return;

  const savedTags = JSON.parse(localStorage.getItem("selectedTags")) || [];

  checkboxes.forEach(checkbox => {
    checkbox.checked = savedTags.includes(checkbox.value);
  });

  const url = new URL(window.location);
  if (url.pathname === "/posts" && !url.searchParams.has("tags") && savedTags.length > 0) {
    url.searchParams.set("tags", savedTags.join(","));
    Turbo.visit(url.toString(), { action: "replace" });
  }

  function openFilter() {
    filterOverlay.style.display = "flex";
    setTimeout(() => {
      filterOverlay.classList.add("show");
    }, 10);
  }

  function closeFilter() {
    filterOverlay.classList.remove("show");
    setTimeout(() => {
      filterOverlay.style.display = "none";
    }, 700);
  }

  filterButton.addEventListener("click", openFilter);
  closeButton.addEventListener("click", closeFilter);
  filterOverlay.addEventListener("click", event => {
    if (event.target === filterOverlay) closeFilter();
  });

  applyFilterButton.addEventListener("click", () => {
    const selectedTags = Array.from(checkboxes)
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value);

    localStorage.setItem("selectedTags", JSON.stringify(selectedTags));

    const newUrl = new URL(window.location.origin + "/posts");
    if (selectedTags.length > 0) {
      newUrl.searchParams.set("tags", selectedTags.join(","));
    }

    Turbo.visit(newUrl.toString(), { action: "replace" });
  });

  clearFilterButton.addEventListener("click", () => {
    checkboxes.forEach(checkbox => checkbox.checked = false);
    localStorage.removeItem("selectedTags");

    Turbo.visit("/posts", { action: "replace" });
  });
}


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

function collectionSearch() {
    const searchInput = document.querySelector(".Q_collectionSearch");
    const collectionList = document.querySelector(".C_collectionList");
    const collections = document.querySelectorAll(".A_collectionObj");
    const noResultsMessage = document.createElement("div");

    if (!searchInput || !collectionList || collections.length === 0) return;

    // Создаём сообщение, если коллекций нет
    noResultsMessage.classList.add("A_noCollectionsMessage");
    noResultsMessage.innerHTML = "<h3>Таких коллекций нет</h3>";
    noResultsMessage.style.display = "none"; // Скрыто по умолчанию
    collectionList.appendChild(noResultsMessage);

    // Функция поиска
    function filterCollections() {
        const query = searchInput.value.toLowerCase().trim();
        let hasResults = false;

        collections.forEach(collection => {
            const title = collection.querySelector("h3").textContent.toLowerCase();
            if (title.includes(query)) {
                collection.style.display = "flex"; // Показываем подходящие коллекции
                hasResults = true;
            } else {
                collection.style.display = "none"; // Скрываем неподходящие
            }
        });

        // Показываем или скрываем сообщение о том, что коллекций нет
        noResultsMessage.style.display = hasResults ? "none" : "block";
    }

    // Запускаем фильтрацию при вводе текста
    searchInput.addEventListener("input", filterCollections);
}

// Загрузка изображения (аватара или поста)
function addImage() {
  const setupImageUpload = (fileInputId, previewClass, imgClass, placeholderClass) => {
    const fileInput = document.getElementById(fileInputId);
    const preview = document.querySelector(`.${previewClass}`);
    const image = preview?.querySelector(`.${imgClass}`);
    const placeholder = preview?.querySelector(`.${placeholderClass}`);

    // 🧠 Сохраняем исходный src (если есть)
    const originalSrc = image?.getAttribute("src");

    if (fileInput) {
      fileInput.addEventListener("change", (event) => {
        const file = event.target.files[0];

        if (file) {
          const reader = new FileReader();

          reader.onload = (e) => {
            if (image) image.src = e.target.result;
            image?.classList.remove("hidden");
            placeholder?.classList.add("hidden");
          };

          reader.readAsDataURL(file);
        }
      });
    }

    // 🔁 Сброс
    const resetBtn = document.querySelector('.Q_settingsResetBtn');
    if (resetBtn && image && placeholder && fileInput) {
      resetBtn.addEventListener('click', () => {
        fileInput.value = "";

        if (originalSrc && originalSrc.trim() !== "") {
          image.src = originalSrc;
          image.classList.remove("hidden");
          placeholder.classList.add("hidden");
        } else {
          image.classList.add("hidden");
          placeholder.classList.remove("hidden");
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
      "A_uploadPostPreview", 
      "Q_postImgUpload", 
      "placeholder" 
    );
    // Для товара
    setupImageUpload(
        "item_image_upload",
        "A_uploadItemPreview",
        "Q_itemImgUpload",
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
      const inputsToCheck = Array.from(form.querySelectorAll("input")).filter((input) =>
        ["text"].includes(input.type)
      );

      const isValid = inputsToCheck.every((input) => input.value.trim() !== "");

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
                icon.src = "/assets/heartIcon_r.svg"; // Меняем на filled
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

// Сохранение в подборки
function saveToCollection() {
    // Открытие/закрытие выпадающего списка коллекций
    document.querySelectorAll(".A_selectedCollection").forEach(selector => {
        selector.addEventListener("click", function () {
            const dropdown = this.closest(".W_saveHeader").nextElementSibling;
            if (dropdown) {
                dropdown.classList.toggle("dropdown");
                this.classList.toggle("active");
            }
        });
    });

    // Поиск по коллекциям
    document.querySelectorAll(".Q_collectionSearch").forEach(input => {
        input.addEventListener("input", function () {
            const searchText = this.value.toLowerCase();
            const collectionItems = this.closest(".W_collectionDropdown").querySelectorAll(".A_collectionObj");

            collectionItems.forEach(item => {
                const collectionName = item.textContent.toLowerCase();
                item.style.display = collectionName.includes(searchText) ? "block" : "none";
            });
        });
    });

    // Выбор коллекции из выпадающего списка
    document.querySelectorAll(".A_collectionObj").forEach(item => {
        item.addEventListener("click", function () {
            const collectionId = this.dataset.collectionId;
            const collectionName = this.textContent.trim();
            const parentContainer = this.closest(".W_collectionDropdown").previousElementSibling;

            const selectedCollection = parentContainer.querySelector(".A_selectedCollection");
            const collectionNameElement = selectedCollection.querySelector(".Q_selectedCollectionName");

            if (selectedCollection && collectionNameElement) {
                selectedCollection.dataset.collectionId = collectionId;
                collectionNameElement.textContent = collectionName;
            }

            const dropdown = this.closest(".W_collectionDropdown");
            dropdown.classList.add("dropdown");
            selectedCollection.classList.remove("active");
        });
    });

    // Кнопки "Сохранить"
    document.querySelectorAll("[data-save-button]").forEach(button => {
        button.addEventListener("click", function () {
            const header = this.closest(".W_saveHeader");
            const collectionSelector = header.querySelector(".A_selectedCollection");
            const collectionId = collectionSelector.dataset.collectionId;

            const postId = collectionSelector.dataset.postId;
            const itemId = collectionSelector.dataset.itemId;

            if (!collectionId) {
                alert("Выберите коллекцию перед сохранением!");
                return;
            }

            let url;
            if (postId) {
                url = `/collections/${collectionId}/toggle_post/${postId}`;
            } else if (itemId) {
                url = `/collections/${collectionId}/toggle_item/${itemId}`;
            } else {
                alert("Не удалось определить, что сохраняем — пост или товар.");
                return;
            }

            fetch(url, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const textButton = header.querySelector('[data-save-button="text"]');
                    const iconButton = header.querySelector('[data-save-button="icon"]');
                    
                    if (data.saved) {
                        textButton.textContent = "Сохранено";
                        textButton.classList.add("saved");
                        iconButton.classList.add("saved");
                        iconButton.querySelector("img").src = "/assets/savedIcon.svg";
                    } else {
                        textButton.textContent = "Сохранить";
                        textButton.classList.remove("saved");
                        iconButton.classList.remove("saved");
                        iconButton.querySelector("img").src = "/assets/saveIcon.svg";
                    }
                } else {
                    alert("Ошибка при сохранении!");
                }
            });
        });
    });

    // Закрытие при клике вне области
    document.addEventListener("click", function (event) {
        const dropdowns = document.querySelectorAll(".W_collectionDropdown");
        dropdowns.forEach(dropdown => {
            const collectionSelector = dropdown.previousElementSibling.querySelector(".A_selectedCollection");
            if (!dropdown.contains(event.target) && !dropdown.previousElementSibling.contains(event.target)) {
                dropdown.classList.add("dropdown");
                collectionSelector.classList.remove("active");
            }
        });
    });
}

function replyToComment() {
    const replyButtons = document.querySelectorAll(".Q_replyBtn");
    const commentForm = document.querySelector(".comment-form");
    const inputField = commentForm?.querySelector(".Q_commentFormInput");
    const parentIdInput = commentForm?.querySelector(".parentCommentIdInput");
  
    if (!replyButtons.length || !commentForm || !inputField || !parentIdInput) return;
  
    replyButtons.forEach((button) => {
      button.addEventListener("click", () => {
        const commentId = button.dataset.commentId;
        const username = button.dataset.commentName;
  
        // Подставляем @имя только если это ответ НЕ на корневой комментарий
        const commentEl = button.closest(".O_postComment");
        const isRootComment = commentEl?.parentElement?.classList.contains("C_postCommentFeed");

        if (!isRootComment) {
        const tag = `${username}, `;
        if (!inputField.value.startsWith(tag)) {
            inputField.value = tag + inputField.value;
        }
        }
  
        // Устанавливаем parent_comment_id
        parentIdInput.value = commentId;
  
        // Фокус на поле
        inputField.focus();
      });
    });
  }

function toggleReplies() {
    document.querySelectorAll(".Q_showReplies").forEach((button) => {
        button.addEventListener("click", () => {
        const commentId = button.dataset.commentId;
        const repliesBlock = document.querySelector(`.C_commentReplies[data-replies-for="${commentId}"]`);

        if (repliesBlock) {
            const isHidden = repliesBlock.classList.toggle("hidden");
            const count = button.getAttribute("data-reply-count");
            button.querySelector("h4").textContent = isHidden
              ? `Показать ответы (${count})`
              : `Скрыть ответы (${count})`;
        }
        });
    });
}

function autoResizeTextarea() {
    document.querySelectorAll(".Q_commentFormInput").forEach((textarea) => {
      // Устанавливаем высоту по содержимому
      const resize = () => {
        textarea.style.height = "auto";
        textarea.style.height = `${textarea.scrollHeight}px`;
      };
  
      textarea.addEventListener("input", resize);
      resize(); // При загрузке
    });
  }

function initProfileFeedToggle() {
    const postTab = document.querySelector(".Q_profileFeedHeader.posts");
    const itemTab = document.querySelector(".Q_profileFeedHeader.items");

    const postFeed = document.querySelector(".C_profileFeedPosts");
    const itemFeed = document.querySelector(".C_profileFeedItems");

    if (!postTab || !itemTab || !postFeed || !itemFeed) return;

    postTab.addEventListener("click", () => {
    postTab.classList.add("active");
    postTab.classList.remove("passive");
    itemTab.classList.add("passive");
    itemTab.classList.remove("active");

    postFeed.style.display = "grid";
    itemFeed.style.display = "none";
    });

    itemTab.addEventListener("click", () => {
    itemTab.classList.add("active");
    itemTab.classList.remove("passive");
    postTab.classList.add("passive");
    postTab.classList.remove("active");

    postFeed.style.display = "none";
    itemFeed.style.display = "grid";
    });
}

function toggleTagsBlock() {
    const toggleButton = document.querySelector(".A_addTagsBtn");
    const tagsList = document.querySelector(".C_tagsList");
  
    if (!toggleButton || !tagsList) return;
  
    toggleButton.addEventListener("click", () => {
      tagsList.classList.toggle("hidden");
      toggleButton.classList.toggle("active");
    });
  }

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
  



  function initFormValidation() {
    const itemNameInput = document.querySelector("input[name='item[name]']");
    const itemPriceInput = document.querySelector("input[name='item[price]']");
    const itemUrlInput = document.querySelector("input[name='item[purchase_url]']");
    const itemImage = document.querySelector(".Q_itemImgUpload");
    const itemSaveBtn = document.querySelector(".O_modalItemForm input[type='submit']");
  
    const findItemUrlInput = document.querySelector(".Q_addItemLinkInput");
    const findItemBtn = document.querySelector(".Q_findItem");
  
    const postImageInput = document.getElementById("post_image_upload");
    const postImagePreview = document.querySelector(".Q_postImgUpload");
    const postTitleInput = document.getElementById("post_title");
    const postDescInput = document.getElementById("post_description");
    const itemsList = document.getElementById("items-list");
    const postSubmitBtn = document.querySelector(".Q_publishPostBtn");
  
    function isValidUrl(url) {
      try {
        const parsed = new URL(url);
        return ["http:", "https:"].includes(parsed.protocol);
      } catch (_) {
        return false;
      }
    }
  
    function checkItemForm() {
      const nameFilled = itemNameInput?.value.trim() !== "";
      const priceFilled = itemPriceInput?.value.trim() !== "";
      const urlFilled = isValidUrl(itemUrlInput?.value.trim());
      const valid = nameFilled && priceFilled && urlFilled;
  
      if (itemSaveBtn) {
        itemSaveBtn.disabled = !valid;
        itemSaveBtn.classList.toggle("active", valid);
      }
  
      if (itemUrlInput) {
        itemUrlInput.setCustomValidity(urlFilled || itemUrlInput.value.trim() === "" ? "" : "Введите корректную ссылку");
      }
    }
  
    function checkFindItemInput() {
      const valid = isValidUrl(findItemUrlInput?.value.trim());
      if (findItemBtn) {
        findItemBtn.disabled = !valid;
        findItemBtn.classList.toggle("active", valid);
      }
    }
  
    function checkPostForm() {
      const title = postTitleInput?.value.trim() !== "";
      const desc = postDescInput?.value.trim() !== "";
      const hasImage = postImageInput?.files?.[0] || !postImagePreview?.classList.contains("hidden");
      const hasItems = itemsList?.querySelectorAll(".M_formItem").length > 0;
  
      const valid = title && desc && hasImage && hasItems;
      if (postSubmitBtn) {
        postSubmitBtn.disabled = !valid;
        postSubmitBtn.classList.toggle("active", valid);
      }
    }
  
    // === Добавим слушатели ===
    [itemNameInput, itemPriceInput, itemUrlInput].forEach(el => {
      el?.addEventListener("input", checkItemForm);
    });
  
    findItemUrlInput?.addEventListener("input", checkFindItemInput);
  
    [postTitleInput, postDescInput, postImageInput].forEach(el => {
      el?.addEventListener("input", checkPostForm);
      el?.addEventListener("change", checkPostForm);
    });
  
    // Следим за добавлением товаров
    const observer = new MutationObserver(checkPostForm);
    if (itemsList) {
      observer.observe(itemsList, { childList: true });
    }
  
    // Первичная проверка
    checkItemForm();
    checkFindItemInput();
    checkPostForm();
  }

  function initItemModalLogic(tempItems = []) {
    const findBtn = document.querySelector(".Q_findItem");
    const urlInput = document.querySelector(".Q_addItemLinkInput");
    const modalWrapper = document.querySelector(".S_modalItemForm"); // обёртка модалки
    const modalForm = modalWrapper?.querySelector(".O_modalItemForm"); // сама форма внутри
    const modalError = document.querySelector(".S_modalItemError");
    const manualBtn = modalError?.querySelector(".Q_addItemButton");
    const closeBtns = document.querySelectorAll(".Q_modalCloseBtn");
  
    const itemsList = document.getElementById("items-list");
    const tempItemsInput = document.getElementById("temp_items_json");
  
    if (!findBtn || !urlInput) return;
  
    // ======== Открытие модалки по ссылке ========
    findBtn.addEventListener("click", async () => {
      const url = urlInput.value.trim();
      if (!url) return alert("Введите ссылку на товар");
  
      try {
        const response = await fetch("/items/fetch_data", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
          },
          body: JSON.stringify({ url })
        });
  
        const data = await response.json();
  
        if (data.success) {
          fillModalForm(data);
          modalWrapper.classList.remove("hidden");
        } else {
          showError();
        }
      } catch (error) {
        console.error(error);
        showError();
      }
    });
  
    // ======== Ручное открытие формы, если фетч не сработал ========
    manualBtn?.addEventListener("click", () => {
      modalError.classList.add("hidden");
      modalWrapper.classList.remove("hidden");
    });
  
    // ======== Закрытие модалки ========
    closeBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        modalWrapper.classList.add("hidden");
        modalError.classList.add("hidden");
      });
    });
  
    // ======== Сохранение товара ========
    modalForm.addEventListener("submit", e => {
      e.preventDefault();
  
      const item = {
        name: modalForm.querySelector("input[name='item[name]']").value.trim(),
        price: modalForm.querySelector("input[name='item[price]']").value.trim(),
        purchase_url: modalForm.querySelector("input[name='item[purchase_url]']").value.trim(),
        image_url: modalForm.querySelector(".Q_itemImgUpload").src
      };
  
      tempItems.push(item);
      updateTempItemsInput();
  
      fetch("/items/preview", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ item })
      })
        .then(res => res.text())
        .then(html => {
          itemsList.insertAdjacentHTML("beforeend", html);
          resetModalForm();
          showNotice("Товар успешно добавлен");
          if (typeof checkPostForm === "function") checkPostForm();
        });
    });
  
    // ======== Удаление товара ========
    document.addEventListener("click", function (e) {
      const deleteBtn = e.target.closest(".Q_deleteItemBtn");
      if (!deleteBtn) return;
  
      const itemBlock = deleteBtn.closest(".M_formItem");
      if (!itemBlock) return;
  
      const name = itemBlock.querySelector(".Q_formItemName")?.textContent.trim();
      const price = itemBlock.querySelector(".Q_formItemPrice")?.textContent.replace(/\D/g, "");
      const url = itemBlock.querySelector(".Q_formItemLink")?.href;
  
      tempItems = tempItems.filter(item => {
        return !(
          item.name.trim() === name &&
          item.price.replace(/\D/g, "") === price &&
          (!url || item.purchase_url === url)
        );
      });
  
      itemBlock.remove();
      const separator = itemBlock.nextElementSibling;
      if (separator?.classList.contains("Q_listItemsLine")) {
        separator.remove();
      }
  
      updateTempItemsInput();
      if (typeof checkPostForm === "function") checkPostForm();
    });
  
    // ======== Вспомогательные ========
    function fillModalForm(data) {
      modalForm.querySelector("#item_image_upload").value = "";
      modalForm.querySelector(".Q_itemImgUpload").src = data.image_url;
      modalForm.querySelector(".Q_itemImgUpload").classList.remove("hidden");
      modalForm.querySelector(".placeholder")?.classList.add("hidden");
  
      modalForm.querySelector("input[name='item[name]']").value = data.name;
      modalForm.querySelector("input[name='item[purchase_url]']").value = data.purchase_url;
      modalForm.querySelector("input[name='item[price]']").value = data.price || "";
    }
  
    function showError() {
      modalError.classList.remove("hidden");
      modalWrapper.classList.add("hidden");
    }
  
    function resetModalForm() {
        modalForm.reset(); // теперь точно форма
        modalWrapper.classList.add("hidden");
        modalForm.querySelector(".Q_itemImgUpload").src = "";
        modalForm.querySelector(".Q_itemImgUpload").classList.add("hidden");
        modalForm.querySelectorAll(".placeholder").forEach(el => el.classList.remove("hidden"));
        urlInput.value = ""; // очищаем поле поиска
        findBtn.disabled = true;
        findBtn.classList.remove("active");
      }
  
    function updateTempItemsInput() {
      if (tempItemsInput) {
        tempItemsInput.value = JSON.stringify(tempItems);
      }
    }
  }
function initSettingsTabs() {
  const navButtons = document.querySelectorAll('.Q_settingsNavBtn');

  navButtons.forEach((btn, index) => {
    btn.addEventListener('click', () => {
      // Активная кнопка
      navButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      // Определяем вкладку
      const tab = btn.innerText.trim().toLowerCase(); // например, "личная информация" → "личная информация"
      let tabSlug = '';

      if (tab.includes('информация')) tabSlug = 'profile';
      else if (tab.includes('безопасность')) tabSlug = 'security';
      else if (tab.includes('уведомления')) tabSlug = 'notifications';
      else if (tab.includes('предпочтения')) tabSlug = 'preferences';

      if (tabSlug) {
        fetch(`/settings/${tabSlug}`)
          .then(res => res.text())
.then(html => {
  document.querySelector('.W_settingsSection').innerHTML = html;
  initSettingsFormsWatcher(); 
  addImage(); // ⬅️ вызываем ТОЛЬКО ПОСЛЕ загрузки HTML
});

      }
    });
  });

  // При открытии модалки грузим первую вкладку (профиль)
  const firstBtn = document.querySelector('.Q_settingsNavBtn');
  if (firstBtn) firstBtn.click();
}

function initSettingsFormsWatcher() {
  const forms = document.querySelectorAll('.W_settingsForm');

  console.log("Найдено форм:", forms.length);

  forms.forEach(form => {
    const buttonsWrapper = document.querySelector('[data-settings-actions]');

    console.log("Нашли кнопки?", !!buttonsWrapper);

    if (!buttonsWrapper) return;

    const showButtons = () => {
      console.log("✏️ Пользователь что-то ввёл");
      buttonsWrapper.style.display = 'flex';
    };

    // Слушаем любое изменение
    form.addEventListener('input', showButtons);
    form.addEventListener('change', showButtons);
        form.addEventListener('submit', e => {
      console.log("📤 Событие submit произошло");
    });

    // Кнопка сброса
    const resetBtn = form.querySelector('[data-reset]');
    console.log("Кнопка сброса есть?", !!resetBtn);

    if (resetBtn) {
      resetBtn.addEventListener('click', e => {
        e.preventDefault();
        console.log("🔄 Сброс формы");
        form.reset();
        buttonsWrapper.style.display = 'none';
      });
    }

    // Прячем кнопки при инициализации
    buttonsWrapper.style.display = 'none';
  });
}



function setupSettingsModalToggle() {
  const openLinks = document.querySelectorAll('[data-open-settings]');
  const closeBtn = document.querySelector('[data-close-settings]');
  const modal = document.querySelector('.S_modalSettings');

  if (!modal) return;

  openLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      modal.classList.remove('hidden');
      initSettingsTabs();      // вкладки
      addImage();              // превью
    });
  });

  if (closeBtn) {
    closeBtn.addEventListener('click', () => {
      modal.classList.add('hidden');
    });
  }
}


function initSuggestionsSlider() {
  const suggestionList = document.querySelector(".C_suggestionList");
  const prevBtn = document.querySelector(".Q_emptyArrow.prev");
  const nextBtn = document.querySelector(".Q_emptyArrow.next");

  const loadSuggestions = (direction) => {
    suggestionList.classList.add(`slide-${direction}-out`);

    fetch("/profiles/suggestions")
      .then(res => res.text())
      .then(html => {
        setTimeout(() => {
          suggestionList.innerHTML = html;
          suggestionList.classList.remove(`slide-${direction}-out`);
          suggestionList.classList.add(`slide-${direction}-in`);
          setTimeout(() => {
            suggestionList.classList.remove(`slide-${direction}-in`);
          }, 300);
        }, 300);
      });
  };

  nextBtn.addEventListener("click", () => loadSuggestions("left"));
  prevBtn.addEventListener("click", () => loadSuggestions("right"));
}




// Инициализация функций
document.addEventListener("turbo:load", () => {
    

    if (document.querySelector('.Q_dropdownBtn')) {
        dropdownMenu();
    }
    systemMessage();


    initSettingsTabs();
    initSettingsFormsWatcher();
    setupSettingsModalToggle();

    changeLayout();
    masonry();

    cardsAppear();
    likeStates();
    
    saveToCollection();
    collectionSearch();

    sort();
    filter();

    initProfileFeedToggle();

    replyToComment();
    toggleReplies();
    autoResizeTextarea();

    toggleTagsBlock();
    selectedTag();

    initFormValidation();
initItemModalLogic();

    
    regSection();
    profileSection();
    addImage();
    toggleSubmitButtonState(".S_firstRegistrationStep form");
    toggleSubmitButtonState(".S_secondRegistrationStep form");
    toggleActionButtonsState("#edit_profile_form", ".C_editProfileActions");

    initSuggestionsSlider();
    
});
document.addEventListener("turbo:before-cache", () => {
    document.querySelectorAll(".A_systemMessage, .systemMessage").forEach(el => el.remove());
});