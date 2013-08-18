// Generated by CoffeeScript 1.4.0
/*
Facebook init
*/

var AlbumsCtrl, FriendsCtrl, MetaCtrl, Photowell, UserCtrl;

FB.init({
  appId: '544498978935917',
  frictionlessRequests: true,
  status: true,
  cookie: true
});

/*
DOM ready
*/


angular.element(document).ready(function() {
  $.scrollUp({
    scrollImg: true
  });
  return $('.fancybox').fancybox({
    openEffect: 'elastic',
    closeEffect: 'elastic',
    helpers: {
      title: {
        type: 'over'
      }
    }
  });
});

/*
App: Photowell
*/


Photowell = angular.module('Photowell', []);

/*
Routes
*/


Photowell.config(function($routeProvider) {
  return $routeProvider.when('/user', {
    controller: UserCtrl,
    templateUrl: 'views/wall.html'
  }).when('/friends', {
    controller: FriendsCtrl,
    templateUrl: 'views/wall.html'
  }).when('/albums', {
    controller: AlbumsCtrl,
    templateUrl: 'views/wall.html'
  }).otherwise({
    redirectTo: '/user'
  });
});

/*
Filter
*/


Photowell.filter('truncate', function() {
  return function(text, length, end) {
    if (!(text != null)) {
      return "";
    }
    if (isNaN(length)) {
      length = 10;
    }
    if (!(end != null)) {
      end = "...";
    }
    if (text.length <= length || text.length - end.length <= length) {
      return text;
    } else {
      return String(text).substring(0, length - end.length) + end;
    }
  };
});

/*
Globale Funktionen
*/


Photowell.run(function($rootScope, Monitor) {
  $rootScope.monitor = Monitor;
  $rootScope.needLoad = function() {
    return $(window).scrollTop() >= ($(document).height() - $(window).height()) * 0.9;
  };
  $rootScope.hasScrollBar = function() {
    return $(document).height() !== $('.scroll').height() + $('.scroll').scrollTop();
  };
  return $rootScope.formatImage = function(image) {
    var source;
    if (image.images[4] >= 320) {
      source = image.images[4].source;
    } else if (image.images[3] >= 320) {
      source = image.images[3].source;
    } else {
      source = image.images[2].source;
    }
    return {
      src: source,
      src_large: image.images[0].source,
      name: image.name != null ? image.name : void 0
    };
  };
});

/*
User factory
*/


Photowell.factory('User', function($rootScope) {
  var storage;
  storage = {
    name: '',
    username: '',
    picture: '',
    access_token: '',
    user_photos: [],
    user_photos_data: [],
    user_photos_data_raw: []
  };
  return {
    set: function(key, value, broadcast) {
      if (broadcast == null) {
        broadcast = true;
      }
      storage[key] = value;
      if (broadcast) {
        $rootScope.$broadcast(key, value);
      }
      return this;
    },
    push: function(key, value, broadcast) {
      if (broadcast == null) {
        broadcast = true;
      }
      storage[key].push(value);
      if (broadcast) {
        $rootScope.$broadcast(key, value);
      }
      return this;
    },
    merge: function(key, value, broadcast) {
      if (broadcast == null) {
        broadcast = true;
      }
      $.merge(storage[key], value);
      if (broadcast) {
        $rootScope.$broadcast(key, value);
      }
      return this;
    },
    get: function(key) {
      return storage[key];
    },
    check: function() {
      if (($rootScope.needLoad() || !$rootScope.hasScrollBar()) && !$rootScope.monitor.get('in_process')) {
        if (this.get('user_photos_data').length === 0) {
          if (this.get('user_photos_data_raw').length === 0) {
            return;
          }
          this.merge('user_photos_data', $.map(this.get('user_photos_data_raw'), function(photo) {
            return $rootScope.formatImage(photo);
          }), false);
          this.set('user_photos_data_raw', [], false);
        }
        $rootScope.monitor.set('in_process', true);
        this.merge('user_photos', this.get('user_photos_data').slice(0, 20));
        this.set('user_photos_data', this.get('user_photos_data').slice(20), false);
        return angular.forEach(this.get('user_photos_data').slice(0, 20), function(img) {
          return (new Image()).src = img.src;
        });
      }
    },
    reset: function() {
      var photos;
      photos = this.get('user_photos');
      this.set('user_photos', photos.slice(0, 20));
      return this.set('user_photos_data', $.merge(photos.slice(20), this.get('user_photos_data')));
    }
  };
});

/*
Friends factory
*/


Photowell.factory('Friends', function($rootScope) {
  var storage;
  storage = {
    friends_photos: [],
    friends_photos_data: [],
    friends_photos_data_raw: []
  };
  return {
    set: function(key, value, broadcast) {
      if (broadcast == null) {
        broadcast = true;
      }
      storage[key] = value;
      if (broadcast) {
        $rootScope.$broadcast(key, value);
      }
      return this;
    },
    push: function(key, value, broadcast) {
      if (broadcast == null) {
        broadcast = true;
      }
      storage[key].push(value);
      if (broadcast) {
        $rootScope.$broadcast(key, value);
      }
      return this;
    },
    merge: function(key, value, broadcast) {
      if (broadcast == null) {
        broadcast = true;
      }
      $.merge(storage[key], value);
      if (broadcast) {
        $rootScope.$broadcast(key, value);
      }
      return this;
    },
    get: function(key) {
      return storage[key];
    },
    check: function() {
      if (($rootScope.needLoad() || !$rootScope.hasScrollBar()) && !$rootScope.monitor.get('in_process')) {
        if (this.get('friends_photos_data').length === 0) {
          if (this.get('friends_photos_data_raw').length === 0) {
            return;
          }
          this.merge('friends_photos_data', $.map(this.get('friends_photos_data_raw'), function(photo) {
            return $rootScope.formatImage(photo);
          }), false);
          this.set('friends_photos_data_raw', [], false);
        }
        $rootScope.monitor.set('in_process', true);
        this.merge('friends_photos', this.get('friends_photos_data').slice(0, 20));
        this.set('friends_photos_data', this.get('friends_photos_data').slice(20), false);
        return angular.forEach(this.get('friends_photos_data').slice(0, 20), function(img) {
          return (new Image()).src = img.src;
        });
      }
    },
    reset: function() {
      var photos;
      photos = this.get('friends_photos');
      this.set('friends_photos', photos.slice(0, 20));
      return this.set('friends_photos_data', $.merge(photos.slice(20), this.get('friends_photos_data')));
    }
  };
});

/*
Albums factory
*/


Photowell.factory('Albums', function($rootScope, Monitor) {
  var storage;
  storage = {
    albums_photos: [],
    albums_photos_data: [],
    albums_photos_data_raw: []
  };
  return {
    set: function(key, value, broadcast) {
      if (broadcast == null) {
        broadcast = true;
      }
      storage[key] = value;
      if (broadcast) {
        $rootScope.$broadcast(key, value);
      }
      return this;
    },
    push: function(key, value, broadcast) {
      if (broadcast == null) {
        broadcast = true;
      }
      storage[key].push(value);
      if (broadcast) {
        $rootScope.$broadcast(key, value);
      }
      return this;
    },
    merge: function(key, value, broadcast) {
      if (broadcast == null) {
        broadcast = true;
      }
      $.merge(storage[key], value);
      if (broadcast) {
        $rootScope.$broadcast(key, value);
      }
      return this;
    },
    get: function(key) {
      return storage[key];
    },
    check: function() {
      if (($rootScope.needLoad() || !$rootScope.hasScrollBar()) && !$rootScope.monitor.get('in_process')) {
        if (this.get('albums_photos_data').length === 0) {
          if (this.get('albums_photos_data_raw').length === 0) {
            return;
          }
          this.merge('albums_photos_data', $.map(this.get('albums_photos_data_raw'), function(photo) {
            return $rootScope.formatImage(photo);
          }));
          this.set('albums_photos_data_raw', [], false);
        }
        $rootScope.monitor.set('in_process', true);
        this.merge('albums_photos', this.get('albums_photos_data').slice(0, 20));
        this.set('albums_photos_data', this.get('albums_photos_data').slice(20), false);
        return angular.forEach(this.get('albums_photos_data').slice(0, 20), function(img) {
          return (new Image()).src = img.src;
        });
      }
    },
    reset: function() {
      var photos;
      photos = this.get('albums_photos');
      this.set('albums_photos', photos.slice(0, 20));
      return this.set('albums_photos_data', $.merge(photos.slice(20), this.get('friends_photos_data')));
    }
  };
});

/*
Monitor factory

Stellt Monitor Objekte bereit um eine Synchrone
*/


Photowell.factory('Monitor', function($rootScope) {
  var monitor;
  monitor = {
    'in_process': false,
    'scope_in_use': ''
  };
  return {
    set: function(key, value) {
      monitor[key] = value;
      return this;
    },
    get: function(key) {
      return monitor[key];
    }
  };
});

/*
Directive: photo-wall

Ein Directive welches dazu dient, nach dem aufbau des DOM's, die 
Bilder neu anzuordnen bzw. die neu dazugekommen Bilder unten richtig anordnen.
*/


Photowell.directive('photoWall', function($rootScope, $timeout) {
  return function(scope, element, attr) {
    if (!scope.$last) {
      return;
    }
    return $timeout(function() {
      scope.container.freetile({
        animate: true
      });
      return $rootScope.monitor.set('in_process', false);
    });
  };
});

/*
Directive: when-scrolled

Ein Directive an dem das scroll-Event angehägt ist.
*/


Photowell.directive('whenScrolled', function(Monitor) {
  return function(scope, elm, attr) {
    var scrollCheck;
    scrollCheck = function(evt) {
      if (Monitor.get('scope_in_use').$id === scope.$id) {
        return scope.factory.check();
      }
    };
    return angular.element(window).bind('scroll load', scrollCheck);
  };
});

/*
Meta Controller
*/


MetaCtrl = function($scope, $location, User, Friends, Albums) {
  FB.getLoginStatus(function(response) {
    if (response.status === 'connected') {
      return User.set('access_token', response.authResponse.accessToken);
    } else {
      $scope.$apply(function() {
        if ($location.$$path !== '/') {
          return $location.path('/');
        }
      });
      return $('#myModal').modal();
    }
  });
  $scope.login = function() {
    return FB.login(function(response) {
      if (response.authResponse) {
        User.set('access_token', response.authResponse.accessToken);
      }
      return $('#myModal').modal('hide');
    }, {
      scope: 'email,user_photos,friends_photos,user_photo_video_tags,friends_photo_video_tags'
    });
  };
  $scope.init = function() {
    return FB.api('/me?fields=name,username,albums.fields(photos.fields(name,images)),friends.fields(id),photos,picture.type(small)&access_token=' + User.get('access_token'), function(user) {
      var int, photos;
      User.set('picture', user.picture.data.url);
      User.set('name', user.name);
      User.set('username', user.username);
      photos = user.photos != null ? user.photos.data : [];
      if (user.albums.data.length !== 0) {
        angular.forEach(user.albums.data, function(album) {
          return $.merge(photos, album.photos.data);
        });
      }
      User.set('user_photos_data_raw', photos);
      $scope.friendsLoad(user.friends.data.pop());
      $scope.friendsLoad(user.friends.data.pop());
      $scope.friendsLoad(user.friends.data.pop());
      $scope.friendsLoad(user.friends.data.pop());
      $scope.friendsLoad(user.friends.data.pop());
      return int = setInterval(function() {
        if (user.friends.data.length === 0) {
          return clearInterval(int);
        }
        return $scope.friendsLoad(user.friends.data.pop());
      }, 1000);
    });
  };
  $scope.friendsLoad = function(friend) {
    return FB.api('/' + friend.id + '?fields=name,photos,albums.fields(photos.fields(name,images))&access_token=' + User.get('access_token'), function(friend) {
      if (friend.photos != null) {
        Friends.merge('friends_photos_data_raw', friend.photos.data);
      }
      if (friend.albums != null) {
        return angular.forEach(friend.albums.data, function(album) {
          if (album.photos != null) {
            return Albums.merge('albums_photos_data_raw', album.photos.data);
          }
        });
      }
    });
  };
  $scope.getClass = function(path) {
    if ($location.path().substr(0, path.length) === path) {
      return "active";
    } else {
      return "";
    }
  };
  $scope.$on('name', function(events, name) {
    return $scope.$apply(function() {
      return $scope.name = name;
    });
  });
  $scope.$on('picture', function(events, picture) {
    return $scope.$apply(function() {
      return $scope.picture = picture;
    });
  });
  return $scope.$on('access_token', function() {
    return $scope.init();
  });
};

/*
User Controller
*/


UserCtrl = function($scope, User, Monitor) {
  Monitor.set('scope_in_use', $scope);
  $scope.container = $('.items');
  $scope.factory = User;
  $scope.monitor = Monitor.set('in_process', false);
  $scope.name = User.get('name');
  $scope.username = User.get('username');
  $scope.picture = User.get('picture');
  if (User.get('user_photos').length !== 0) {
    $scope.factory.reset();
  } else {
    $scope.factory.check();
  }
  $scope.photos = User.get('user_photos');
  $scope.$on('name', function(events, name) {
    return $scope.$apply(function() {
      return $scope.name = name;
    });
  });
  $scope.$on('username', function(events, username) {
    return $scope.$apply(function() {
      return $scope.username = username;
    });
  });
  $scope.$on('picture', function(events, picture) {
    return $scope.$apply(function() {
      return $scope.picture = picture;
    });
  });
  $scope.$on('user_photos', function() {
    if (!$scope.$$phase) {
      return $scope.$apply();
    }
  });
  $scope.$on('user_photos_data', function() {
    return $scope.check();
  });
  $scope.$on('user_photos_data_raw', function() {
    return $scope.factory.check();
  });
  if (User.get('user_photos_data_raw').length !== 0) {
    return $scope.factory.check();
  }
};

/*
Friends Controller
*/


FriendsCtrl = function($scope, Friends, Monitor) {
  Monitor.set('scope_in_use', $scope);
  $scope.container = $('.items');
  $scope.factory = Friends;
  if (Friends.get('friends_photos').length !== 0) {
    $scope.factory.reset();
  } else {
    $scope.factory.check();
  }
  $scope.photos = Friends.get('friends_photos');
  $scope.$on('friends_photos', function() {
    if (!$scope.$$phase) {
      return $scope.$apply();
    }
  });
  $scope.$on('friends_photos_data_raw', function() {
    return $scope.factory.check();
  });
  if (Friends.get('friends_photos_data_raw').length !== 0) {
    return $scope.factory.check();
  }
};

/*
Album Controller
*/


AlbumsCtrl = function($scope, User, Albums, Friends, Monitor) {
  Monitor.set('scope_in_use', $scope);
  $scope.container = $('.items');
  $scope.factory = Albums;
  if (Albums.get('albums_photos').length !== 0) {
    $scope.factory.reset();
  } else {
    $scope.factory.check();
  }
  $scope.photos = Albums.get('albums_photos');
  $scope.$on('albums_photos', function() {
    if (!$scope.$$phase) {
      return $scope.$apply();
    }
  });
  $scope.$on('albums_photos_data_raw', function() {
    return $scope.factory.check();
  });
  if (Albums.get('albums_photos_data_raw').length !== 0) {
    return $scope.factory.check();
  }
};
