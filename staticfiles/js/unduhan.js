$(document).ready(function() {
    new DataTable('#unduhan', {
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