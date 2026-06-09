// Wait until the HTML document is fully loaded before running the script
document.addEventListener('DOMContentLoaded', () => {

    // Select all elements that should be revealed when scrolling
    const sections = document.querySelectorAll('.reveal');

    // Animation settings
    const revealDistance = 150; // Distance from bottom of viewport before revealing

    // These variables can be used for future animation customization
    const initialOpacity = 0;
    const transitionDelay = 0;
    const transitionDuration = '2s';
    const transitionProperty = 'all';
    const transitionTimingFunction = 'ease';

    // Function that adds the "revealed" class to a section
    // This class should contain the CSS animation effects
    const revealSection = (section) => {
        section.classList.add('revealed');
    };

    // Check whether a section has entered the viewport
    const isInViewport = (section) => {
        const rect = section.getBoundingClientRect();

        // Return true when the section is close enough to be visible
        return rect.top <= window.innerHeight - revealDistance;
    };

    // Function executed whenever the user scrolls
    const handleScroll = () => {

        // Loop through each reveal section
        sections.forEach((section) => {

            // Reveal the section if it is visible in the viewport
            if (isInViewport(section)) {
                revealSection(section);
            }

        });
    };

    // Accessibility feature:
    // Disable animations if the user prefers reduced motion
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {

        sections.forEach((section) => {
            section.style.transition = 'none';
        });

    }

    // Reveal sections already visible when the page loads
    handleScroll();

    // Listen for scroll events and reveal sections as needed
    window.addEventListener('scroll', handleScroll);

});