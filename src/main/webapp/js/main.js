// IDUKA Main JavaScript

function toggleMenu(){
  const nav=document.getElementById('mobileNav');
  nav.classList.toggle('open');
}

// Close menu when clicking outside
document.addEventListener('click',function(e){
  const nav=document.getElementById('mobileNav');
  const btn=document.querySelector('.hamburger');
  if(nav && !nav.contains(e.target) && btn && !btn.contains(e.target)){
    nav.classList.remove('open');
  }
});

// Auto-dismiss alerts
document.querySelectorAll('.alert').forEach(function(el){
  setTimeout(function(){ el.style.opacity='0'; el.style.transition='opacity 0.5s'; setTimeout(function(){el.remove();},500); }, 5000);
});
