window.addEventListener("load", function () {
    document.getElementById('searchForm').addEventListener("submit", function (e) {
        e.preventDefault(); // before the code
        doSearch(document.getElementById('searchText').value)
    })

    let pathname = window.location.pathname;
    document.getElementById('searchText').value = pathname.substr(pathname.lastIndexOf('/') + 1);

});

function doSearch(searchText) {
    window.location.href = '/search/' + searchText;
}