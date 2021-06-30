window.addEventListener("load", function () {
    document.getElementById('searchForm').addEventListener("submit", function (e) {
        e.preventDefault(); // before the code
        doSearch(document.getElementById('searchText').value)
    })

    if (window.location.href.indexOf('/search/') > -1) {
        let pathname = window.location.pathname;
        document.getElementById('searchText').value = pathname.substr(pathname.lastIndexOf('/') + 1);
    }
});

function doSearch(searchText) {
    if (searchText && searchText.length > 2) {
        window.location.href = '/search/' + searchText;
    }
}