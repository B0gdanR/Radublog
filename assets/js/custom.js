// Create image modal/lightbox with better styling
document.addEventListener('DOMContentLoaded', function() {
    // Create modal elements
    const modal = document.createElement('div');
    modal.style.cssText = `
        display: none;
        position: fixed;
        z-index: 9999;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0,0,0,0.95);
        cursor: pointer;
    `;

	const modalImg = document.createElement('img');
	modalImg.style.cssText = `
		margin: auto;
		display: block;
		width: auto;
		height: auto;
		min-width: 70%;
		min-height: 70%;
		max-width: 85%;
		max-height: 85%;
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		border-radius: 8px;
		box-shadow: 0 4px 20px rgba(0,0,0,0.5);
		object-fit: contain;
	`;

    // Add close hint text
    const closeHint = document.createElement('div');
    closeHint.innerHTML = 'Click anywhere or press ESC to close';
    closeHint.style.cssText = `
        position: absolute;
        top: 20px;
        left: 50%;
        transform: translateX(-50%);
        color: white;
        font-size: 14px;
        opacity: 0.8;
    `;

    modal.appendChild(modalImg);
    modal.appendChild(closeHint);
    document.body.appendChild(modal);

    // Make content images clickable
    const contentImages = document.querySelectorAll('.content img');
    
    contentImages.forEach(function(img) {
        img.addEventListener('click', function() {
            modalImg.src = img.src;
            modal.style.display = 'block';
            document.body.style.overflow = 'hidden'; // Prevent scrolling
        });
    });

    // Close modal function
    function closeModal() {
        modal.style.display = 'none';
        document.body.style.overflow = 'auto'; // Restore scrolling
    }

    // Close modal when clicking outside the image
    modal.addEventListener('click', closeModal);

    // Close modal with ESC key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeModal();
        }
    });
});