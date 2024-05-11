$(document).ready(function() {
    new DataTable('#paketAktif', {
        layout: {
            topStart: null,
            topEnd: null,
            bottomStart:null,
            bottomEnd: null,
        },
        "language": {
            "emptyTable": "Tidak ada paket aktif"
        },
        paging: false,
        pageLength: 50
    });
});  

$(document).ready(function() {
    new DataTable('#pilihanPaket', {
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

$(document).ready(function() {
    new DataTable('#riwayatPaket', {
        layout: {
            topStart: null,
            topEnd: null,
            bottomStart:null,
            bottomEnd: null,
        },
        "language": {
            "emptyTable": "Tidak ada riwayat paket"
        },
        paging: false,
        pageLength: 50
    });
});  