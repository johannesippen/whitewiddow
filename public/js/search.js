var searchStyle = document.getElementById('search_style');
document.getElementById('search').addEventListener('input', function() {
  if (!this.value) {
    searchStyle.innerHTML = "";
    return;
  }
  // look ma, no indexOf!
  searchStyle.innerHTML = ".fb_friend:not([data-index*=\"" + this.value.toLowerCase() + "\"]) { display: none; }";
  // beware of css injections!
});

$(function(){
  $('.fb_friend button').live('touchend mouseup',function(){
    // Add Friend here
    return false;
  });
})