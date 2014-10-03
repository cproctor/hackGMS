
// This script gives the page a disease. Pieces of the page are slowly eaten by the page!
// jQuery must be loaded in the page for it to run.

var incubation_period = 700;

var disease = function() {
  var diseased_element = find_diseased_element()  
  $(diseased_element).animate(
    {'opacity': 0},
    incubation_period,
    undefined,
    function() {
      var diseased_text = $(diseased_element).text() || 'empty element';
      console.log("Goodbye, " + diseased_text);
      $(diseased_element).remove();
      disease();
    });
}

var find_diseased_element = function() {
  return find_element_with_no_children($('body'));
}

var find_element_with_no_children = function(element) {
  var children = $(element).children();
  if (children.length == 0) {
    return element;
  }
  else {
    return find_element_with_no_children(choose_random_element(children));
  }
}

var choose_random_element = function(list) {
  var index = Math.floor(Math.random() * list.length);
  return list[index]
}

disease()
