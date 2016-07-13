jQuery(function ($) {
    var main = $('#main-content'),
        repo = main.attr('data-repo');

    function onFail(req, text, error) {
        alert("AJAX request failed: " + text + " " + error);
    }

    function get(endpoint, callback) {
        main.empty();
        $.get('/api/' + endpoint)
            .done(callback)
            .fail(onFail);
    }

    function post(endpoint, data, callback) {
        $.post('/api/' + endpoint, JSON.stringify(data))
            .done(callback)
            .fail(onFail);
    }


    function listRepos() {
        get('list', function (repoList) {
            var ul = $('<ul></ul>');
            $.each(repoList, function (i, repoItem) {
                $('<a></a>')
                    .text(repoItem.name + ' (' + repoItem.left + ' left)')
                    .attr('href', '#')
                    .click(function () {
                        repo = repoItem.name;
                        referencify();
                    })
                    .appendTo($('<li></li>').appendTo(ul));
            });
            ul.appendTo(main);
        });
    }


    function addLists(count) {
        var first;
        for (var i = 0; i < count; ++i) {
            var ul = $('<ul></ul>')
                .addClass('well')
                .addClass('list-unstyled')
                .addClass('artifacts')
                .appendTo(main);
            first = first || ul;
        }
        $('.artifacts').sortable({connectWith : '.artifacts'});
        return first;
    }

    function addTuple(list, tuple) {
        var link = $('<a></a>')
            .text(tuple[0] + ' <' + tuple[1] + '>')
            .addClass('btn')
            .addClass('btn-default')
            .css('width', '100%');
        return $('<li></li>')
            .attr('data-name', tuple[0])
            .attr('data-mail', tuple[1])
            .css('line-height', '3em')
            .append(link)
            .appendTo(list);
    }

    function addButton(name) {
        var button = $('<button></button>')
            .text('Submit')
            .addClass('btn')
            .addClass('btn-success')
            .css('width', '100%')
            .appendTo(main);
        button.click(function () {
            button.attr('disabled', true);
            postSelection(name);
        });
        return button;
    }

    function referencify() {
        get('repo/' + repo, function (res) {
            if (res.left) {
                var list = addLists(res.identity.length);
                $.each(res.identity, function (i, tuple) {
                    addTuple(list, tuple);
                });
                addButton(res.name);
            }
            else {
                listRepos();
            }
        });
    }


    function postSelection(name) {
        var results = [];
        var lists   = $('.artifacts');

        for (var i = 0; i < lists.length; ++i) {
            var items  = $(lists[i]).find('li');
            var tuples = [];
            for (var j = 0; j < items.length; ++j) {
                var item = $(items[j]);
                tuples.push([item.attr('data-name'), item.attr('data-mail')]);
            }
            results.push(tuples);
        }

        post('repo/' + repo, {name : name, identities : results}, function () {
            referencify();
        });
    }


    if (repo) {
        referencify();
    }
    else {
        listRepos();
    }
});
