// Add JavaScript functionality for the Community Free Library website

document.addEventListener('DOMContentLoaded', () => {

    // Get references to important HTML elements
    const form = document.getElementById('sign-petition');
    const signaturesList = document.getElementById('signatures-list');
    const totalSignatures = document.getElementById('total-signatures');
    const toggleModeButton = document.getElementById('toggle-mode');

    // Initial number of signatures already displayed on the page
    let signatureCount = 4;

    // ==========================================
    // Dark Mode Toggle Feature
    // ==========================================

    // Switch between light mode and dark mode when button is clicked
    toggleModeButton.addEventListener('click', () => {
        document.body.classList.toggle('dark-mode');
    });

    // ==========================================
    // Petition Form Submission
    // ==========================================

    // Listen for form submission
    form.addEventListener('submit', (e) => {

        // Prevent page from reloading after form submission
        e.preventDefault();

        // Retrieve and clean user input values
        const name = document.getElementById('name').value.trim();
        const email = document.getElementById('email').value.trim();
        const city = document.getElementById('city').value.trim();

        // ==========================================
        // Input Validation
        // ==========================================

        // Ensure user enters a valid name and email address
        if (!name || !email.includes('@')) {
            alert('Please provide a valid name and email address.');
            return;
        }

        // ==========================================
        // Add New Signature
        // ==========================================

        // Create a new paragraph element for the signature
        const newSignature = document.createElement('p');

        // Increase signature count and display the new signer
        newSignature.textContent = `${++signatureCount}. ${name}, ${city || 'N/A'}`;

        // Add the new signature to the signatures list
        signaturesList.appendChild(newSignature);

        // ==========================================
        // Update Signature Counter
        // ==========================================

        // Display the updated total number of signatures
        totalSignatures.textContent = `Total Signatures: ${signatureCount}`;

        // ==========================================
        // Reset Form
        // ==========================================

        // Clear all form fields after successful submission
        form.reset();

    });

});