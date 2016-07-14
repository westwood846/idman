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


    function makeArtifactList() {
        return $('<ul></ul>')
            .addClass('well')
            .addClass('list-unstyled')
            .addClass('artifacts');
    }


    function listRepos() {
        get('list', function (repoList) {
            var ul = $('<ul></ul>');
            $.each(repoList, function (i, repoItem) {
                var repoLink = $('<a></a>')
                    .text(repoItem.name + ' (' + repoItem.left + ' left)')
                    .attr('href', '#')
                    .click(function () {
                        repo = repoItem.name;
                        referencify();
                    });

                var resultButton = $('<a></a>')
                    .text('Results')
                    .attr('href', '#')
                    .click(function () {
                        repo = repoItem.name;
                        showResults();
                    });

                $('<li></li>')
                    .append(repoLink)
                    .append(' - ')
                    .append(resultButton)
                    .appendTo(ul);
            });
            ul.appendTo(main);
        });
    }


    function addLists(count) {
        var first;
        for (var i = 0; i < count; ++i) {
            var ul = makeArtifactList().appendTo(main);
            first = first || ul;
        }
        $('.artifacts').sortable({connectWith : '.artifacts'});
        return first;
    }

    function appendToNextEmptyList() {
        var current = $(this);
        $(current.parent().parent().children().get().reverse()).each(function() {
            if ($(this).is(':empty')) {
                $(this).append(current);
                return;
            }
        });
    }

    function addTuple(list, tuple) {
        var name = $('<div></div>')
            .addClass('col-sm-6')
            .css('text-align', 'right')
            .text(tuple[0] + ' ');
        var email = $('<div></div>')
            .addClass('col-sm-6')
            .css('text-align', 'left')
            .text('<' + tuple[1] + '>');
        var link = $('<a></a>')
            .append(name)
            .append(email)
            .addClass('btn')
            .addClass('btn-default')
            .css('width', '100%');
        return $('<li></li>')
            .attr('data-name', tuple[0])
            .attr('data-mail', tuple[1])
            .css('line-height', '3em')
            .dblclick(appendToNextEmptyList)
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


    function showResults() {
        get('results/' + repo, function (res) {
            var keys = Object.keys(res);
            keys.sort(function (a, b) { return a - b; });

            $.each(keys, function (i, key) {
                var panel = $('<div></div>')
                    .addClass('panel')
                    .addClass('panel-default')
                    .appendTo(main);

                var button = $('<button></button>')
                    .text('Undo')
                    .addClass('btn')
                    .addClass('btn-danger')
                    .click(function () {
                        post('results/' + repo, {key : key}, function () {
                            panel.remove();
                        });
                    });

                var head = $('<div></div>')
                    .text(key)
                    .addClass('panel-heading')
                    .append(' ')
                    .append(button)
                    .appendTo(panel);

                var body = $('<div></div>')
                    .addClass('panel-body')
                    .appendTo(panel);

                var identities = res[key];
                $.each(identities, function (i, identity) {
                    var ul = makeArtifactList().appendTo(body);
                    $.each(identity, function (j, tuple) {
                        addTuple(ul, tuple);
                    });
                });
            });
        });
    }


    if (repo) {
        referencify();
    }
    else {
        listRepos();
    }
});
