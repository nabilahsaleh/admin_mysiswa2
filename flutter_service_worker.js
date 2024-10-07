self.addEventListener('install', (event) => {
    console.log('Service worker installed.');
    self.skipWaiting();
  });
  
  self.addEventListener('activate', (event) => {
    console.log('Service worker activated.');
  });
  
  self.addEventListener('fetch', (event) => {
    // You can intercept fetch requests here if needed
    console.log('Service worker fetching:', event.request.url);
  });
  
  self.addEventListener('push', (event) => {
    console.log('Push received: ', event);
  
    const data = event.data ? event.data.json() : {};
    const title = data.title || 'New Notification';
    const body = data.body || 'You have a new message.';
    const options = {
      body: body,
      icon: 'assets/notification.png',  // Optional icon
    };
  
    event.waitUntil(
      self.registration.showNotification(title, options)
    );
  });
  