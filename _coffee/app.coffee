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
    $('.fancybox').fancybox {
        openEffect: 'elastic' 
        closeEffect: 'elastic'
        helpers: {
            title: {
                type: 'over'
            }
        }
    }

###
App: Photowell
###
Photowell = angular.module 'Photowell', []

###
Routes
###
Photowell.config ($routeProvider)->
    $routeProvider.
        when('/', controller: UserCtrl, templateUrl: 'views/user.html').
        when('/stream', controller: StreamCtrl, templateUrl: 'views/stream.html').
        when('/friends', controller: FriendsCtrl, templateUrl: 'views/friends.html').
        when('/albums', controller: AlbumsCtrl, templateUrl: 'views/albums.html').
        otherwise(redirectTo:'/')

###
Globale Funktionen    
###
Photowell.run ($rootScope)->
    # falls die Seite zu 90% gescrollt wurde wird ein 'true' zurück gegeben
    $rootScope.needLoad = ->
        $(window).scrollTop() >= ($(document).height() - $(window).height()) * 0.9

    # schaut nach ob eine ScrollBar vorhanden ist
    $rootScope.hasScrollBar = ->
        $(document).height() isnt $(window).height() + $(window).scrollTop()

    # holt aus den Bild Objekten die von Facebook kommen die für uns relevanten Daten raus
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
    
    return {
        set: (key, value, broadcast = true)->
            storage[key] = value
            $rootScope.$broadcast key, value if broadcast

            return @

        push: (key, value, broadcast = true)->
            storage[key].push value
            $rootScope.$broadcast key, value if broadcast

            return @

        merge: (key, value, broadcast = true)->
            $.merge storage[key], value
            $rootScope.$broadcast key, value if broadcast

            return @ 

        get: (key)->
            storage[key]

    }

###
Friends factory
###
Photowell.factory 'Friends', ($rootScope)->   
    storage = 
        friends_photos_data: []
        friends_photos: []
    
    return {
        set: (key, value, broadcast = true)->
            storage[key] = value
            $rootScope.$broadcast key, value if broadcast

            return @

        push: (key, value, broadcast = true)->
            storage[key].push value
            $rootScope.$broadcast key, value if broadcast

            return @

        merge: (key, value, broadcast = true)->
            $.merge storage[key], value
            $rootScope.$broadcast key, value if broadcast

            return @

        get: (key)->
            storage[key]

    }


###
Overlay factory

Speichert das Overlay Element, so das es nur einmal vorhanden ist und 
von allen Controllern benutzt werden kann.
###
Photowell.factory 'Overlay', ($rootScope)->
    overlay = null

    return {
        set: (value)->
            overlay = value

            return @

        get: ()->
            overlay
    }

###
Monitor factory

Stellt Monitor Objekte bereit um eine Synchrone 
###
Photowell.factory 'Monitor', ($rootScope)->
    monitor = 
        'in_process' 

    return {
        set: (key, value)->
            monitor[key] = value

            return @

        get: (key)->
            monitor[key]
    }

###
Directive: photo-wall

Ein Directive welches dazu dient, nach dem aufbau des DOM's, die 
Bilder neu anzuordnen bzw. die neu dazugekommen Bilder unten richtig anordnen.
###
Photowell.directive 'photoWall', ($timeout)-> 
    (scope, element, attr)-> 
        return if not scope.$last

        $timeout ->
            scope.container.freetile
                animate: true 

            scope.monitor.set 'in_process', no


###
Directive: when-scrolled

Ein Directive an dem das scroll-Event angehägt ist.
###
Photowell.directive 'whenScrolled', ()->
    (scope, elm, attr)->
        scrollCheck = (evt)-> scope.check()

        angular.element(window).bind('scroll load', scrollCheck)      

###
Meta Controller
###
MetaCtrl = ($scope, $location, User, Overlay)->
    Overlay.set $('.overlay') 

    FB.getLoginStatus (response)-> 
        if response.status is 'connected'
            User.set 'access_token', response.authResponse.accessToken
        else
            $scope.$apply -> $location.path '/' if $location.$$path isnt '/'
            
            Overlay.get().fadeIn()  

    $scope.login = ->
        FB.login (response)->
            User.set 'access_token', response.authResponse.accessToken if response.authResponse
        ,
        scope: 'email,user_photos,friends_photos,user_photo_video_tags,friends_photo_video_tags'

    $scope.init = ->
        FB.api '/me?fields=name,username,albums,photos,picture.type(large)&access_token=' + User.get('access_token'), (user)->
            User.set 'picture', user.picture.data.url
            User.set 'name', user.name
            User.set 'username', user.username
            User.set 'user_photos_data', $.map user.photos.data, (photo)-> $scope.formatImage photo 

            angular.forEach user.albums.data, (album)->
                FB.api '/' + album.id + '/photos?fields=name,images&access_token=' + User.get('access_token'), (photos)-> 
                    User.merge 'user_photos_data', $.map photos.data, (photo)-> $scope.formatImage photo

            Overlay.get().fadeOut('slow')

    $scope.$on 'name', (events, name)->
        $scope.$apply -> $scope.name = name    

    $scope.$on 'access_token', (events, access_token)->
        $scope.init()

###
User Controller
###
UserCtrl = ($scope, User, Overlay, Monitor)->
    $scope.container = $('.container')

    $scope.monitor = Monitor.set 'in_process', no

    $scope.name = User.get 'name'

    $scope.username = User.get 'username'
    
    $scope.picture = User.get 'picture'

    $scope.photos = User.get 'user_photos'

    $scope.check = ->
        if ($scope.needLoad() or not $scope.hasScrollBar()) and not $scope.monitor.get 'in_process'
            return if User.get('user_photos_data').length is 0

            $scope.monitor.set 'in_process', yes

            User.merge 'user_photos', User.get('user_photos_data').slice 0, 20

            User.set 'user_photos_data', User.get('user_photos_data').slice(20), false

            # preload
            angular.forEach User.get('user_photos_data').slice(0, 20), (img)-> (new Image()).src = img.src

    $scope.$on 'name', (events, name)-> $scope.$apply -> 
        $scope.name = name

    $scope.$on 'username', (events, username)-> 
        $scope.$apply -> $scope.username = username

    $scope.$on 'picture', (events, picture)-> 
        $scope.$apply -> $scope.picture = picture

    $scope.$on 'user_photos', (events, user_photos)->
        # Voodoo
        $scope.$apply -> 

    $scope.$on 'user_photos_data', (events, user_photos_data)->
        $scope.check()

    $scope.check() if User.get('user_photos_data').length isnt 0

###
Stream Controller
###
StreamCtrl = ($scope)->

###
Friends Controller
###
FriendsCtrl = ($scope, Friends, User, Monitor)->
    $scope.container = $('.container')

    $scope.monitor = Monitor.set 'in_process', no

    $scope.images = Friends.get 'friends_photos'

    $scope.init = ->
        FB.api '/me/friends?fields=name,username,albums,picture.type(square)&access_token=' + User.get('access_token'), (friends)->
            angular.forEach friends.data, (friend)->
                ###
                Albums.set 'picture', friend.picture.data.url
                Albums.set 'name', friend.name
                Albums.set 'username', friend.username
                Albums.set 'albums', friend.albums.data
                ###

                # if friend.albums?
                FB.api '/' + friend.id + '/photos?fields=name,images&access_token=' + User.get('access_token'), (photos)->
                    Friends.set 'friends_photos_data', $.merge Friends.get('friends_photos_data'), $.map photos.data, (photo)-> $scope.formatImage photo

    $scope.check = ->
        if ($scope.needLoad() or not $scope.hasScrollBar()) and not $scope.monitor.get 'in_process'
            return if Friends.get('friends_photos_data').length < 20

            $scope.monitor.set 'in_process', yes

            Friends.merge 'friends_photos', Friends.get('friends_photos_data').slice 0, 20

            Friends.set 'friends_photos_data', Friends.get('friends_photos_data').slice(20), false

            # Friends.set 'friends_photos', $.merge(Friends.get('friends_photos'), photos)

            # $scope.$apply -> $.merge $scope.images, photos

            angular.forEach Friends.get('friends_photos_data').slice(0, 20), (img)-> (new Image()).src = img.src

    ###
    FB.getLoginStatus (response)-> 
        if response.status isnt 'connected'
            $scope.$apply ->
                $location.path '/'
        else 

            FB.api '/me/friends?fields=name,username,albums,picture.type(square)&access_token=' + User.get('access_token'), (response)->
                $scope.friends = []
                $scope.images = []

                $.each response.data, (index, user)->
                    $scope.$apply ->
                        $scope.friends.push 
                            picture: user.picture.data.url
                            name: user.name
                            username: user.username

                    return true if not user.albums?

                    FB.api '/' + user.id + '/photos?fields=name,images&access_token=' + User.get('access_token'), (response)-> 
                        images = []

                        $.each response.data, (index, image)->
                            if image.images[4] >= 320
                                source = image.images[4].source
                            else if image.images[3] >= 320
                                source = image.images[3].source
                            else 
                                source = image.images[2].source

                            images.push
                                src: source
                                src_large: image.images[0].source
                                name: image.name if image.name?
                        
                        $scope.$apply ->
                            $.merge $scope.images_container, images  

                        $scope.check()
    ###

    $scope.$on 'friends_photos', (events, friends_photos)->
        $scope.$apply -> 

    $scope.$on 'friends_photos_data', (events, friends_photos_data)->
        $scope.check()

    $scope.$on 'access_token', (events, photos_data)->
        $scope.init()

    if Friends.get('friends_photos_data').length isnt 0
        $scope.check()

    if User.get('access_token')
        $scope.init()

###
Album Controller
###
AlbumsCtrl = ($scope)->


