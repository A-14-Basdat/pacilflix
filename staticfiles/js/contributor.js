$(document).ready(function() {
    new DataTable('#contributors', {
        layout: {
            topStart: null,
            topEnd: null,
            bottomStart:null,
            bottomEnd: null,
        },
        paging: false,
        pageLength: 50
    });
});

document.addEventListener("DOMContentLoaded", function() {
    // Get the dropdown button element
    var dropdownButton = document.getElementById('dropdownMenuButton');
    
    // Add a click event listener to the dropdown button
    dropdownButton.addEventListener('click', function() {
        // Toggle the dropdown menu visibility
        var dropdownMenu = dropdownButton.nextElementSibling;
        dropdownMenu.classList.toggle('show');
    });
});