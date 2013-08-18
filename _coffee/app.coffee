###
Facebook init
###
FB.init
    appId :'544498978935917'
    frictionlessRequests : true
    status : true
    cookie : true

###
DOM ready
###
angular.element(document).ready ->
    $.scrollUp scrollImg: true


    $('.fancybox').fancybox 
        openEffect: 'elastic' 
        closeEffect: 'elastic'
        helpers: 
            title: 
                type: 'over' 

###
App: Photowell
###
Photowell = angular.module 'Photowell', []

###
Routes
###
Photowell.config ($routeProvider)->
    $routeProvider.
        when('/user', controller: UserCtrl, templateUrl: 'views/wall.html').
        when('/friends', controller: FriendsCtrl, templateUrl: 'views/wall.html').
        when('/albums', controller: AlbumsCtrl, templateUrl: 'views/wall.html').
        otherwise(redirectTo:'/user')

###
Filter
###
Photowell.filter 'truncate', ->
    (text, length, end)->
        return "" if not text?

        length = 10 if isNaN(length)

        end = "..." if not end?

        if text.length <= length || text.length - end.length <= length
            text
        else 
            String(text).substring(0, length-end.length) + end
        
###
Globale Funktionen    
###
Photowell.run ($rootScope, Monitor)->
    $rootScope.monitor = Monitor

    # falls die Seite zu 90% gescrollt wurde wird ein 'true' zurück gegeben
    $rootScope.needLoad = ->
        # $('.scroll').scrollTop() >= ($('.scroll').get(0).scrollHeight - $(document).height()) * 0.9
        $(window).scrollTop() >= ($(document).height() - $(window).height()) * 0.9

    # schaut nach ob eine ScrollBar vorhanden ist
    $rootScope.hasScrollBar = ->
        $(document).height() isnt $('.scroll').height() + $('.scroll').scrollTop()

    $rootScope.formatImage = (image)->
        if image.images[4] >= 320
            source = image.images[4].source
        else if image.images[3] >= 320
            source = image.images[3].source
        else 
            source = image.images[2].source

        return {
            src: source
            src_large: image.images[0].source
            name: image.name if image.name?
        }

###
User factory
###
Photowell.factory 'User', ($rootScope)->   
    storage = 
        name: ''
        username: ''
        picture: ''
        access_token: ''
        user_photos: []
        user_photos_data: []
        user_photos_data_raw: []
    
    return {
        set: (key, value, broadcast = true)->
            storage[key] = value
            $rootScope.$broadcast key, value if broadcast

            @

        push: (key, value, broadcast = true)->
            storage[key].push value
            $rootScope.$broadcast key, value if broadcast

            @

        merge: (key, value, broadcast = true)->
            $.merge storage[key], value
            $rootScope.$broadcast key, value if broadcast

            @ 

        get: (key)->
            storage[key]

        check: ->
            if ($rootScope.needLoad() or not $rootScope.hasScrollBar()) and not $rootScope.monitor.get 'in_process'
                if @get('user_photos_data').length is 0
                    return if @get('user_photos_data_raw').length is 0

                    @merge 'user_photos_data', $.map(@get('user_photos_data_raw'), (photo)-> $rootScope.formatImage photo), false
                    @set 'user_photos_data_raw', [], false

                $rootScope.monitor.set 'in_process', yes

                @merge 'user_photos', @get('user_photos_data')[0..19]

                @set 'user_photos_data', @get('user_photos_data')[20..], false

                # preload
                angular.forEach @get('user_photos_data')[0..19], (img)-> (new Image()).src = img.src

        reset: ->
            photos = @get('user_photos')
            @set 'user_photos', photos[0..19]

            @set 'user_photos_data', $.merge photos[20..], @get 'user_photos_data'

    }

###
Friends factory
###
Photowell.factory 'Friends', ($rootScope)->   
    storage = 
        friends_photos: []
        friends_photos_data: []
        friends_photos_data_raw: []
    
    return {
        set: (key, value, broadcast = true)->
            storage[key] = value
            $rootScope.$broadcast key, value if broadcast

            @

        push: (key, value, broadcast = true)->
            storage[key].push value
            $rootScope.$broadcast key, value if broadcast

            @

        merge: (key, value, broadcast = true)->
            $.merge storage[key], value
            $rootScope.$broadcast key, value if broadcast

            @

        get: (key)-> 
            storage[key]

        check: ->
            if ($rootScope.needLoad() or not $rootScope.hasScrollBar()) and not $rootScope.monitor.get 'in_process'
                if @get('friends_photos_data').length is 0
                    return if @get('friends_photos_data_raw').length is 0

                    @merge 'friends_photos_data', $.map(@get('friends_photos_data_raw'), (photo)-> $rootScope.formatImage photo), false
                    @set 'friends_photos_data_raw', [], false

                $rootScope.monitor.set 'in_process', yes

                @merge 'friends_photos', @get('friends_photos_data')[0..19]

                @set 'friends_photos_data', @get('friends_photos_data')[20..], false

                # preload
                angular.forEach @get('friends_photos_data')[0..19], (img)-> (new Image()).src = img.src

        reset: ->
            photos = @get('friends_photos')
            @set 'friends_photos', photos[0..19]

            @set 'friends_photos_data', $.merge photos[20..], @get 'friends_photos_data'
    }

###
Albums factory
###
Photowell.factory 'Albums', ($rootScope, Monitor)->   
    storage = 
        albums_photos: []
        albums_photos_data: []
        albums_photos_data_raw: []
    
    return {
        set: (key, value, broadcast = true)->
            storage[key] = value
            $rootScope.$broadcast key, value if broadcast

            @

        push: (key, value, broadcast = true)->
            storage[key].push value
            $rootScope.$broadcast key, value if broadcast

            @

        merge: (key, value, broadcast = true)->
            $.merge storage[key], value
            $rootScope.$broadcast key, value if broadcast

            @

        get: (key)->
            storage[key]

        check: ->  
            if ($rootScope.needLoad() or not $rootScope.hasScrollBar()) and not $rootScope.monitor.get 'in_process'
                if @get('albums_photos_data').length is 0
                    return if @get('albums_photos_data_raw').length is 0

                    @merge 'albums_photos_data', $.map @get('albums_photos_data_raw'), (photo)-> $rootScope.formatImage photo
                    @set 'albums_photos_data_raw', [], false


                $rootScope.monitor.set 'in_process', yes

                @merge 'albums_photos', @get('albums_photos_data')[0..19]

                @set 'albums_photos_data', @get('albums_photos_data')[20..], false

                # preload
                angular.forEach @get('albums_photos_data')[0..19], (img)-> (new Image()).src = img.src

        reset: ->
            photos = @get('albums_photos')
            @set 'albums_photos', photos[0..19]

            @set 'albums_photos_data', $.merge photos[20..], @get 'friends_photos_data'

    }

###
Monitor factory

Stellt Monitor Objekte bereit um eine Synchrone 
###
Photowell.factory 'Monitor', ($rootScope)->
    monitor = 
        'in_process': no
        'scope_in_use': ''

    return {
        set: (key, value)->
            monitor[key] = value

            @

        get: (key)->
            monitor[key]

    }

###
Directive: photo-wall

Ein Directive welches dazu dient, nach dem aufbau des DOM's, die 
Bilder neu anzuordnen bzw. die neu dazugekommen Bilder unten richtig anordnen.
###
Photowell.directive 'photoWall', ($rootScope, $timeout)-> 
    (scope, element, attr)-> 
        return if not scope.$last

        $timeout ->
            scope.container.freetile animate: true 

            $rootScope.monitor.set 'in_process', no

###
Directive: when-scrolled

Ein Directive an dem das scroll-Event angehägt ist.
###
Photowell.directive 'whenScrolled', (Monitor)->
    (scope, elm, attr)-> 
        scrollCheck = (evt)-> 
            scope.factory.check() if Monitor.get('scope_in_use').$id is scope.$id

        angular.element(window).bind 'scroll load', scrollCheck  

###
Meta Controller
###
MetaCtrl = ($scope, $location, User, Friends, Albums)->
    FB.getLoginStatus (response)-> 
        if response.status is 'connected'
            User.set 'access_token', response.authResponse.accessToken
        else
            $scope.$apply -> $location.path '/' if $location.$$path isnt '/'
            
            $('#myModal').modal()

    $scope.login = ->
        FB.login (response)->
            User.set 'access_token', response.authResponse.accessToken if response.authResponse
            
            $('#myModal').modal('hide')
        ,
        scope: 'email,user_photos,friends_photos,user_photo_video_tags,friends_photo_video_tags'

    $scope.init = ->
        FB.api '/me?fields=name,username,albums.fields(photos.fields(name,images)),friends.fields(id),photos,picture.type(small)&access_token=' + User.get('access_token'), (user)->
            User.set 'picture', user.picture.data.url
            User.set 'name', user.name
            User.set 'username', user.username
            
            photos = if user.photos? then user.photos.data else []

            if user.albums.data.length isnt 0
                angular.forEach user.albums.data, (album)-> $.merge photos, album.photos.data

            User.set 'user_photos_data_raw', photos
            
            $scope.friendsLoad(user.friends.data.pop())
            $scope.friendsLoad(user.friends.data.pop())
            $scope.friendsLoad(user.friends.data.pop())
            $scope.friendsLoad(user.friends.data.pop())
            $scope.friendsLoad(user.friends.data.pop())

            int = setInterval ->
                return clearInterval(int) if user.friends.data.length is 0

                $scope.friendsLoad(user.friends.data.pop())
            , 1000

    $scope.friendsLoad = (friend)->
        FB.api '/' + friend.id + '?fields=name,photos,albums.fields(photos.fields(name,images))&access_token=' + User.get('access_token'), (friend)->
            Friends.merge 'friends_photos_data_raw', friend.photos.data if friend.photos?

            if friend.albums?
                angular.forEach friend.albums.data, (album)->  
                    Albums.merge 'albums_photos_data_raw', album.photos.data if album.photos?

    $scope.getClass = (path)-> if $location.path().substr(0, path.length) == path then "active" else ""

    $scope.$on 'name', (events, name)-> $scope.$apply -> $scope.name = name    

    $scope.$on 'picture', (events, picture)-> $scope.$apply -> $scope.picture = picture    

    $scope.$on 'access_token', -> $scope.init()

###
User Controller
###
UserCtrl = ($scope, User, Monitor)->
    Monitor.set 'scope_in_use', $scope

    $scope.container = $('.items')

    $scope.factory = User

    $scope.monitor = Monitor.set 'in_process', no

    $scope.name = User.get 'name'

    $scope.username = User.get 'username'
    
    $scope.picture = User.get 'picture'

    if User.get('user_photos').length isnt 0  
        $scope.factory.reset()
    else 
        $scope.factory.check()

    $scope.photos = User.get 'user_photos'

    $scope.$on 'name', (events, name)-> $scope.$apply -> $scope.name = name

    $scope.$on 'username', (events, username)-> $scope.$apply -> $scope.username = username

    $scope.$on 'picture', (events, picture)-> $scope.$apply -> $scope.picture = picture

    $scope.$on 'user_photos', -> $scope.$apply() if not $scope.$$phase

    $scope.$on 'user_photos_data', -> $scope.check()

    $scope.$on 'user_photos_data_raw', -> $scope.factory.check()

    $scope.factory.check() if User.get('user_photos_data_raw').length isnt 0

###
Friends Controller
###
FriendsCtrl = ($scope, Friends, Monitor)->
    Monitor.set 'scope_in_use', $scope

    $scope.container = $('.items')

    $scope.factory = Friends
    
    if Friends.get('friends_photos').length isnt 0  
        $scope.factory.reset()
    else 
        $scope.factory.check()

    $scope.photos = Friends.get 'friends_photos'

    $scope.$on 'friends_photos', -> $scope.$apply() if not $scope.$$phase 

    $scope.$on 'friends_photos_data_raw', -> $scope.factory.check()

    $scope.factory.check() if Friends.get('friends_photos_data_raw').length isnt 0  

###
Album Controller
###
AlbumsCtrl = ($scope, User, Albums, Friends, Monitor)->
    Monitor.set 'scope_in_use', $scope

    $scope.container = $('.items')

    $scope.factory = Albums

    if Albums.get('albums_photos').length isnt 0  
        $scope.factory.reset()
    else 
        $scope.factory.check()

    $scope.photos = Albums.get 'albums_photos'

    $scope.$on 'albums_photos', -> $scope.$apply() if not $scope.$$phase 

    $scope.$on 'albums_photos_data_raw', -> $scope.factory.check()

    $scope.factory.check() if Albums.get('albums_photos_data_raw').length isnt 0