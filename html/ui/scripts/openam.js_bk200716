
function getCookie(cname) {
    var name = cname + "=",
        ca = document.cookie.split(';'),
        i,
        c,
        ca_length = ca.length;
    for (i = 0; i < ca_length; i += 1) {
        c = ca[i];
        while (c.charAt(0) === ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) !== -1) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
};

function getGroup() {
   var tmp=getCookie('HTTP_group');
   var tmps = tmp.split('=');
   tmp = tmps[1].split(',');
   return tmp[0];
};


function openam() {
   var group = getGroup();

if (group == 'cndp-admin-users') {
   var i = document.getElementById('mesos');
   if ( i != null) {
      i.style.display='inline';
      var i = document.getElementById('marathon');
      i.style.display='inline';
      var i = document.getElementById('kubernetes');
      i.style.display='inline';
      var i = document.getElementById('consul');
      i.style.display='inline';
      var i = document.getElementById('traefik');
      i.style.display='inline';
   } 
}


if (group == 'cndp-k8s-users') {
   var i = document.getElementById('kubernetes');
   if ( i != null) {
      i.style.display='inline';
   } 
}

if (group == 'cndp-mesos-users') {
   var i = document.getElementById('mesos');
   if ( i != null) {
      i.style.display='inline';
      var i = document.getElementById('marathon');
      i.style.display='inline';
   }
}


   if ( i == null) { setTimeout(openam, 0) } 
}

function openam_menu() {
   var openam_user = getCookie('HTTP_CUSTOM-uid');
   var openam_div = document.getElementById('openam_login');
   if ( openam_div != null) {
      openam_div.innerHTML="<ul class='menu'><li><a href=#>SIGNED IN AS: "+ openam_user +"</a><ul class='submenu'><li><a href='"+openam_logout+"'>LOG OUT</a></li></ul></li></ul>";

}

   if ( openam_div == null) { setTimeout(openam_menu, 0) }

}

