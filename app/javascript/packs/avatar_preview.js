document.addEventListener("DOMContentLoaded", () => {
  const fileInput = document.getElementById("user_avatar");
  const previewImage = document.getElementById("avatar-preview");

  if (fileInput && previewImage) {
    fileInput.addEventListener("change", (event) => {
      const file = event.target.files[0];
      if (!file) return;

      const reader = new FileReader();
      reader.onload = (e) => {
        previewImage.src = e.target.result;
        previewImage.style.display = "block";
      };
      reader.readAsDataURL(file);
    });
  }
});
