$(document).ready(function() {
    new DataTable('#namaTabel', {
        layout: {
            topStart: null,
            topEnd: null,
            bottomStart:null,
            bottomEnd: null
        },
        "columnDefs": [
            { "orderable": false, "targets": 2 }
          ]
    });
});