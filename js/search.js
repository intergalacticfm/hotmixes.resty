window.addEventListener("load", function () {
    document.getElementById('searchForm').addEventListener("submit", function (e) {
        e.preventDefault(); // before the code
        doSearch(document.getElementById('searchText').value)
    })
});

function doSearch(searchText) {
    console.log(searchText);
    window.location.href = '/search/' + searchText;
}