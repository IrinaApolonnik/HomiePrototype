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
  systemMessage(); 
};

window.showFlashAlert = function(message) {
  const flash = document.createElement('div');
  flash.className = 'A_systemMessage systemMessage--error'; 
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
        const savedLayout = localStorage.getItem("feedLayout") || "big";
        postsFeed.classList.add(savedLayout);

        layoutButtons.forEach(button => {
            const isBigLayout = button.querySelector("img").getAttribute("src").includes("bigLayoutIcon");
            if ((savedLayout === "big" && isBigLayout) || (savedLayout === "compact" && !isBigLayout)) {
                button.classList.add("active");
            }
        });

        layoutButtons.forEach(button => {
            button.addEventListener("click", function () {
                layoutButtons.forEach(btn => btn.classList.remove("active"));
                this.classList.add("active");

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

                localStorage.setItem("feedLayout", newLayout);
            });
        });
    }
}

function masonry() {
    const feed = document.querySelector("#C_postsFeed");

    if (!feed) return console.error("Masonry Error: #C_postsFeed не найден");

    function getGutterSize() {
        return Math.round(window.innerWidth * 0.015);
    }

    function getColumnCount(isBigLayout) {
      const width = window.innerWidth;

      if (isBigLayout) {
        if (width < 743) return 1;         
        else if (width < 1023) return 2;     
        else if (width < 1279) return 3;     
        else return 3;                       
      } else {
        if (width < 743) return 2;
        else if (width < 1023) return 3;
        else if (width < 1279) return 5;
        else return 5;
      }
    }

    function getColumnWidth() {
      const containerWidth = feed.clientWidth;
      const gutter = getGutterSize();
      const isBigLayout = feed.classList.contains("big");

      const columns = getColumnCount(isBigLayout);
      return (containerWidth - (columns - 1) * gutter) / columns;
    }

    function setPostSizes() {
        const posts = document.querySelectorAll(".O_post");
        const colWidth = getColumnWidth();
        
        posts.forEach(post => {
            post.style.width = `${colWidth}px`;
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
        setPostSizes(); 
        msnry.options.columnWidth = getColumnWidth();
        msnry.options.gutter = getGutterSize();
        msnry.layout();
    }

    const observer = new MutationObserver(() => {
        console.log("Masonry: Изменился класс", feed.className);
        setTimeout(updateMasonry, 100);
    });

    observer.observe(feed, {
        attributes: true,
        attributeFilter: ["class"],
    });

    window.addEventListener("resize", updateMasonry);

    setTimeout(updateMasonry, 0);
}

function sort() {
    const sortOptions = document.querySelectorAll(".A_filterSort input[name='sort']");
    const applySortButton = document.querySelector(".A_showResult");
    const sortButton = document.querySelector(".Q_feedSortBtn");
    const sortOverlay = document.querySelector(".S_sort");
    const closeButton = document.querySelector(".Q_closeBtn");

    if (!sortOptions.length || !applySortButton || !closeButton || !sortButton || !sortOverlay) return;

    const savedSort = localStorage.getItem("selectedSort") || "new";

    const url = new URL(window.location);
    const currentSort = url.searchParams.get("sort");

    if (!currentSort && savedSort !== "new") {
        url.searchParams.set("sort", savedSort);
        
        window.history.pushState({}, "", url.toString()); 
    }

    sortOptions.forEach(option => {
        if (option.value === savedSort) {
            option.checked = true;
        }
    });

    applySortButton.addEventListener("click", () => {
        const selectedSort = document.querySelector(".A_filterSort input[name='sort']:checked").value;

        localStorage.setItem("selectedSort", selectedSort);

        if (selectedSort === currentSort) return;

        url.searchParams.set("sort", selectedSort);
        Turbo.visit(url.toString(), { action: "replace" });
    });

    sortButton.addEventListener("click", () => {
        sortOverlay.style.display = "flex";
        setTimeout(() => {
            sortOverlay.classList.add("show");
        }, 10);
    });

    function closeSort() {
        sortOverlay.classList.remove("show");
        setTimeout(() => {
            sortOverlay.style.display = "none";
        }, 700);
    }

    closeButton.addEventListener("click", closeSort);

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
        const delay = element.getAttribute("data-delay") || "0s";
        element.style.animationDelay = delay;

        element.classList.add("slideUpAppear");
    });
}

function collectionSearch() {
    const searchInput = document.querySelector(".Q_collectionSearch");
    const collectionList = document.querySelector(".C_collectionList");
    const collections = document.querySelectorAll(".A_collectionObj");
    const noResultsMessage = document.createElement("div");

    if (!searchInput || !collectionList || collections.length === 0) return;

    noResultsMessage.classList.add("A_noCollectionsMessage");
    noResultsMessage.innerHTML = "<h3>Таких коллекций нет</h3>";
    noResultsMessage.style.display = "none";
    collectionList.appendChild(noResultsMessage);

    function filterCollections() {
        const query = searchInput.value.toLowerCase().trim();
        let hasResults = false;

        collections.forEach(collection => {
            const title = collection.querySelector("h3").textContent.toLowerCase();
            if (title.includes(query)) {
                collection.style.display = "flex"; 
                hasResults = true;
            } else {
                collection.style.display = "none"; 
            }
        });

        noResultsMessage.style.display = hasResults ? "none" : "block";
    }

    searchInput.addEventListener("input", filterCollections);
}

function addImage() {
  const setupImageUpload = (fileInputId, previewClass, imgClass, placeholderClass) => {
    const fileInput = document.getElementById(fileInputId);
    const preview = document.querySelector(`.${previewClass}`);
    const image = preview?.querySelector(`.${imgClass}`);
    const placeholder = preview?.querySelector(`.${placeholderClass}`);

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
    setupImageUpload(
      "post_image_upload", 
      "A_uploadPostPreview", 
      "Q_postImgUpload", 
      "placeholder" 
    );
    setupImageUpload(
        "item_image_upload",
        "A_uploadItemPreview",
        "Q_itemImgUpload",
        "placeholder"
    );
    setupImageUpload(
        "collection_image_upload",
        "A_uploadItemPreview",
        "Q_itemImgUpload",
        "placeholder"
    );
  }

function dropdownMenu() {
    const dropdownButton = document.querySelector('.Q_dropdownBtn');
    const dropdownMenu = document.querySelector('.W_dropdownProfileMenu');

    dropdownButton.addEventListener('click', () => {
        dropdownMenu.classList.toggle('active');
    });

    document.addEventListener('click', (event) => {
        if (!dropdownMenu.contains(event.target) && !dropdownButton.contains(event.target)) {
            dropdownMenu.classList.remove('active');
        }
    });
}

function regSection() {
    const registrationFormSelector = ".S_firstRegistrationStep form";

    toggleSubmitButtonState(registrationFormSelector); 

    const registrationForm = document.querySelector(registrationFormSelector);

    if (registrationForm) {
        const submitButton = registrationForm.querySelector("input[type=submit]");

        registrationForm.addEventListener("submit", async (event) => {
            event.preventDefault(); 
            const formData = new FormData(registrationForm);

            submitButton.disabled = true; 

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
                submitButton.disabled = false; 
            }
        });
    }
}

function profileSection() {
    const profileFormSelector = ".S_secondRegistrationStep form";

    toggleSubmitButtonState(profileFormSelector); 

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

    function checkFormValidity() {
      const inputsToCheck = Array.from(form.querySelectorAll("input")).filter((input) =>
        ["text"].includes(input.type)
      );

      const isValid = inputsToCheck.every((input) => input.value.trim() !== "");

      submitButton.disabled = !isValid;
      submitButton.classList.toggle("disabled", !isValid);
    }

    form.addEventListener("input", checkFormValidity);

    checkFormValidity();
}

function toggleActionButtonsState(formSelector, actionsSelector) {
    const form = document.querySelector(formSelector);
    const actionButtons = document.querySelector(actionsSelector);

    if (!form || !actionButtons) return;

    function checkFormChanges() {
        const isChanged = Array.from(form.querySelectorAll("input, textarea, select")).some((input) => {
            if (input.type === "file") {
                return input.files.length > 0; 
            }
            return input.defaultValue !== input.value.trim(); 
        });

        actionButtons.classList.toggle("hidden", !isChanged);
    }

    form.addEventListener("input", checkFormChanges);

    checkFormChanges();
}

function likeStates() {
    document.querySelectorAll(".Q_likeBtn").forEach((button) => {
        button.addEventListener("click", async (event) => {
            event.preventDefault();

            const likesCountElement = button.parentElement.querySelector(".Q_likesCount");
            const icon = button.querySelector("img");

            if (!likesCountElement || !icon) {
                console.error("Не удалось найти элементы лайка.");
                return;
            }

            const likeableId = button.dataset.id;
            const isLiked = button.dataset.liked === "true";
            const likeableType = button.dataset.type; 

            if (!likeableId || !likeableType) {
                console.error("Отсутствуют необходимые данные для лайка.");
                return;
            }

            let likesCount = parseInt(likesCountElement.dataset.likes, 10);

            if (isLiked) {
                likesCount -= 1;
                icon.src = "/assets/heartIcon_b.svg"; 
            } else {
                likesCount += 1;
                icon.src = "/assets/heartIcon_r.svg"; 
            }

            button.classList.add("likeAnimation");
            likesCountElement.classList.add("likeAnimation");

            setTimeout(() => {
                button.classList.remove("likeAnimation");
                likesCountElement.classList.remove("likeAnimation");
            }, 300);

            likesCountElement.textContent = likesCount;
            likesCountElement.dataset.likes = likesCount;
            button.dataset.liked = (!isLiked).toString();

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

                likesCountElement.textContent = data.likes_count;
                likesCountElement.dataset.likes = data.likes_count;
                button.dataset.liked = data.liked.toString();
            } catch (error) {
                console.error(error);

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

function saveToCollection() {
    const lastSelectedCollectionId = localStorage.getItem("last_selected_collection_id");
    const lastSelectedCollectionName = localStorage.getItem("last_selected_collection_name");

    document.querySelectorAll(".A_selectedCollection").forEach(selector => {
        if (lastSelectedCollectionId && lastSelectedCollectionName) {
            selector.dataset.collectionId = lastSelectedCollectionId;
            selector.querySelector(".Q_selectedCollectionName").textContent = lastSelectedCollectionName;
        }
    });

    document.querySelectorAll(".A_selectedCollection").forEach(selector => {
        selector.addEventListener("click", function () {
            const dropdown = this.closest(".W_saveHeader").nextElementSibling;
            if (dropdown) {
                dropdown.classList.toggle("dropdown");
                this.classList.toggle("active");
            }
        });
    });

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
  document.querySelectorAll(".A_collectionObj").forEach(item => {
      item.addEventListener("click", function () {
          const collectionId = this.dataset.collectionId;
          const collectionName = this.textContent.trim();

          localStorage.setItem("last_selected_collection_id", collectionId);
          localStorage.setItem("last_selected_collection_name", collectionName);

          document.querySelectorAll(".A_selectedCollection").forEach(selector => {
              selector.dataset.collectionId = collectionId;
              selector.querySelector(".Q_selectedCollectionName").textContent = collectionName;
          });

          const dropdown = this.closest(".W_collectionDropdown");
          const selectedCollection = dropdown.previousElementSibling.querySelector(".A_selectedCollection");
          dropdown.classList.add("dropdown");
          selectedCollection.classList.remove("active");
      });
      
  });

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
                });
        });
    });

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
  
        const commentEl = button.closest(".O_postComment");
        const isRootComment = commentEl?.parentElement?.classList.contains("C_postCommentFeed");

        if (!isRootComment) {
        const tag = `${username}, `;
        if (!inputField.value.startsWith(tag)) {
            inputField.value = tag + inputField.value;
        }
        }
  
        parentIdInput.value = commentId;

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
      const resize = () => {
        textarea.style.height = "auto";
        textarea.style.height = `${textarea.scrollHeight}px`;
      };
  
      textarea.addEventListener("input", resize);
      resize();
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

function initCollectionFeedToggle() {
  const postTab = document.querySelector(".Q_collectionFeedToggle.posts");
  const itemTab = document.querySelector(".Q_collectionFeedToggle.items");

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
  
    [itemNameInput, itemPriceInput, itemUrlInput].forEach(el => {
      el?.addEventListener("input", checkItemForm);
    });
  
    findItemUrlInput?.addEventListener("input", checkFindItemInput);
  
    [postTitleInput, postDescInput, postImageInput].forEach(el => {
      el?.addEventListener("input", checkPostForm);
      el?.addEventListener("change", checkPostForm);
    });
  
    const observer = new MutationObserver(checkPostForm);
    if (itemsList) {
      observer.observe(itemsList, { childList: true });
    }
  
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

    if (window.existingItems && Array.isArray(window.existingItems)) {
      existingItems.forEach(item => tempItems.push(item));
    }

    if (!findBtn || !urlInput) return;
  
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
  
    manualBtn?.addEventListener("click", () => {
      modalError.classList.add("hidden");
      modalWrapper.classList.remove("hidden");
    });
  
    closeBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        modalWrapper.classList.add("hidden");
        modalError.classList.add("hidden");
      });
    });
  
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
        modalForm.reset(); 
        modalWrapper.classList.add("hidden");
        modalForm.querySelector(".Q_itemImgUpload").src = "";
        modalForm.querySelector(".Q_itemImgUpload").classList.add("hidden");
        modalForm.querySelectorAll(".placeholder").forEach(el => el.classList.remove("hidden"));
        urlInput.value = "";
        findBtn.disabled = true;
        findBtn.classList.remove("active");
      }
  
    function updateTempItemsInput() {
      if (tempItemsInput) {
        tempItemsInput.value = JSON.stringify(tempItems);
      }
    }
  }

function initCollectionModalLogic() {
  const editBtns = document.querySelectorAll(".Q_createCollectionBtn");
  const modal = document.getElementById("modal_collection");

  if (!editBtns.length || !modal) return;

  editBtns.forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      modal.classList.remove("hidden");
    });
  });

  const closeBtns = modal.querySelectorAll(".Q_modalCloseBtn");
  closeBtns.forEach((btn) => {
    btn.addEventListener("click", () => {
      modal.classList.add("hidden");
    });
  });
}

function initCollectionFormLogic() {
  const form = document.getElementById("collection_form");
  if (!form) return;

  const titleInput = form.querySelector("input[name='collection[title]']");
  const submitBtn = form.querySelector(".Q_newCollectionBtn");

  if (!titleInput || !submitBtn) return;

  titleInput.addEventListener("input", () => {
    const hasTitle = titleInput.value.trim().length > 0;
    submitBtn.disabled = !hasTitle;
    submitBtn.classList.toggle("active", hasTitle);
  });
}

function initEditCollectionModalLogic() {
  const editBtns = document.querySelectorAll(".Q_editCollectionBtn");
  const modal = document.getElementById("modal_collection");

  if (!editBtns.length || !modal) return;

  editBtns.forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      modal.classList.remove("hidden");
    });
  });

  const closeBtns = modal.querySelectorAll(".Q_modalCloseBtn");
  closeBtns.forEach((btn) => {
    btn.addEventListener("click", () => {
      modal.classList.add("hidden");
    });
  });
}

function initEditCollectionFormLogic() {
  const form = document.getElementById("collection_form");
  if (!form) return;

  const titleInput = form.querySelector("input[name='collection[title]']");
  const submitBtn = form.querySelector(".Q_editCollectionBtn");

  if (!titleInput || !submitBtn) return;

  titleInput.addEventListener("input", () => {
    const hasTitle = titleInput.value.trim().length > 0;
    submitBtn.disabled = !hasTitle;
    submitBtn.classList.toggle("active", hasTitle);
  });
}

function initSettingsTabs() {
  const navButtons = document.querySelectorAll('.Q_settingsNavBtn');

  navButtons.forEach((btn, index) => {
    btn.addEventListener('click', () => {

      navButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const tab = btn.innerText.trim().toLowerCase(); 
      let tabSlug = '';

      if (tab.includes('информация')) tabSlug = 'profile';
      else if (tab.includes('безопасность')) tabSlug = 'security';
      else if (tab.includes('уведомления')) tabSlug = 'notifications';

      if (tabSlug) {
        fetch(`/settings/${tabSlug}`)
          .then(res => res.text())
        .then(html => {
          document.querySelector('.W_settingsSection').innerHTML = html;
          initSettingsFormsWatcher(); 
          addImage();
        });
      }
    });
  });
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
      console.log("Пользователь что-то ввёл");
      buttonsWrapper.style.display = 'flex';
    };

    form.addEventListener('input', showButtons);
    form.addEventListener('change', showButtons);
        form.addEventListener('submit', e => {
      console.log("Событие submit произошло");
    });

    const resetBtn = form.querySelector('[data-reset]');
    console.log("Кнопка сброса есть?", !!resetBtn);

    if (resetBtn) {
      resetBtn.addEventListener('click', e => {
        e.preventDefault();
        console.log("Сброс формы");
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
      initSettingsTabs();     
      addImage();              
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

  if (!suggestionList || !prevBtn || !nextBtn) return;

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

function initSearchMenuLogic() {
  const openSearchBtns = document.querySelectorAll(".Q_openSearchBtn, .Q_footerLink.search-link");
  const searchDropdowns = document.querySelectorAll("#search_dropdown");
  const clearSearchBtns = document.querySelectorAll(".Q_clearSearchBtn");
  const closeSearchBtns = document.querySelectorAll("[data-close-search]");

  openSearchBtns.forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      searchDropdowns.forEach((dropdown) => {
        dropdown.classList.toggle("hidden");
        const input = dropdown.querySelector(".Q_searchInput");
        if (!dropdown.classList.contains("hidden")) {
          setTimeout(() => input?.focus(), 100);
        }
      });
    });
  });

  clearSearchBtns.forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      const url = new URL(window.location.href);
      url.searchParams.delete("query");
      window.location.href = url.toString();
    });
  });

  closeSearchBtns.forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      searchDropdowns.forEach((dropdown) => {
        dropdown.classList.add("hidden");
      });
    });
  });
}

function initMobileMenu() {
  const menuButton = document.getElementById("mobile_menu");
  const overlay = document.getElementById("mobile_menu_overlay");
  const closeButton = document.getElementById("close_mobile_menu");

  if (!menuButton || !overlay || !closeButton) return;

  menuButton.addEventListener("click", () => {
    overlay.classList.remove("hidden");
    document.body.classList.add("no-scroll");
  });

  closeButton.addEventListener("click", () => {
    overlay.classList.add("hidden");
    document.body.classList.remove("no-scroll");
  });
}

function markNotificationsAsRead() {
  fetch("/notifications/mark_all_as_read", {
    method: "PATCH",
    headers: {
      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
      "Content-Type": "application/json"
    },
    credentials: "same-origin"
  });
}
function initCopyLinkButtons() {
  document.querySelectorAll('[data-copy-link]').forEach((btn) => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const link = btn.dataset.url;
      if (!link) return;

      navigator.clipboard.writeText(link).then(() => {
        showFlashNotice('Ссылка успешно скопирована!');
      }).catch(() => {
        showFlashAlert('Не удалось скопировать ссылку');
      });
    });
  });
}








// Основная инициализация при загрузке страницы (Turbo)
document.addEventListener("turbo:load", () => {

    // —–– Условные инициализации –––
    
    // Выпадающее меню
    if (document.querySelector('.Q_dropdownBtn')) {
        dropdownMenu();
    }

    // Отметить уведомления как прочитанные на странице уведомлений
    if (document.querySelector("#notifications-page")) {
        markNotificationsAsRead();
    }

    // Системные сообщения
    systemMessage();


    // —–– Настройки профиля –––

    initSettingsTabs();              // Переключение вкладок в настройках
    initSettingsFormsWatcher();      // Отслеживание изменений в формах
    setupSettingsModalToggle();      // Открытие/закрытие модальных окон настроек


    // —–– Лента / Карточки / Сетка –––

    changeLayout();    // Переключение вида (сеткой/списком)
    masonry();         // Сетка Masonry

    cardsAppear();     // Анимация появления карточек
    likeStates();      // Состояние лайков


    // —–– Коллекции –––

    saveToCollection();             // Сохранение в коллекцию
    collectionSearch();            // Поиск по коллекциям

    sort();                         // Сортировка
    filter();                       // Фильтрация

    initProfileFeedToggle();       // Переключение ленты профиля
    initCollectionFeedToggle();    // Переключение ленты коллекций


    // —–– Комментарии –––

    replyToComment();      // Ответ на комментарий
    toggleReplies();       // Показ/скрытие ответов
    autoResizeTextarea();  // Автоматическое изменение размера textarea


    // —–– Теги –––

    toggleTagsBlock();     // Открытие/скрытие блока тегов
    selectedTag();         // Логика выбора тега


    // —–– Формы и модальные окна –––

    initFormValidation();         // Валидация форм
    initItemModalLogic();         // Модалка добавления товара

    initCollectionModalLogic();        // Создание коллекции
    initCollectionFormLogic();         // Логика формы коллекции
    initEditCollectionModalLogic();    // Редактирование коллекции (модалка)
    initEditCollectionFormLogic();     // Логика формы редактирования


    // —–– Регистрация и профиль –––

    regSection();                   // Регистрационный блок
    profileSection();              // Секция профиля
    addImage();                    // Загрузка аватара/фото

    toggleSubmitButtonState(".S_firstRegistrationStep form");   // Кнопка на 1 шаге
    toggleSubmitButtonState(".S_secondRegistrationStep form");  // Кнопка на 2 шаге

    toggleActionButtonsState("#edit_profile_form", ".C_editProfileActions"); // Кнопки профиля (дважды, видимо по ошибке)
    

    // —–– Интерфейс –––

    initSuggestionsSlider();  // Слайдер с предложениями
    initSearchMenuLogic();    // Логика меню поиска
    initMobileMenu();         // Мобильное меню
    initCopyLinkButtons();    // Копирование ссылок
});


// Очистка системных сообщений перед кэшированием страницы (Turbo)
document.addEventListener("turbo:before-cache", () => {
    document.querySelectorAll(".A_systemMessage, .systemMessage").forEach(el => el.remove());
});


