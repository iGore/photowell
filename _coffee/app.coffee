needLoad = ->
    $(window).scrollTop() >= ($(document).height() - $(window).height()) * 0.9

hasScrollBar = ->
    $(document).height() isnt $(window).height() + $(window).scrollTop()

$ ->
    $('.fancybox').fancybox {
        openEffect: 'elastic' 
        closeEffect: 'elastic'
        helpers: {
            title: {
                type: 'over'
            }
        }
    }

FB.init
    appId :'544498978935917'
    frictionlessRequests : true
    status : true
    cookie : true

Photowell = angular.module 'Photowell', []

Photowell.config ($routeProvider)->
    $routeProvider.
        when('/', controller: UserCtrl, templateUrl: 'views/user.html').
        when('/stream', controller: PhotowellCtrl, templateUrl: 'views/stream.html').
        when('/friends', controller: FriendsCtrl, templateUrl: 'views/friends.html').
        when('/albums', controller: AlbumsCtrl, templateUrl: 'views/albums.html').
        otherwise({redirectTo:'/'})

Photowell.factory 'User', ($rootScope)->   
    storage = 
        name: ''
        username: ''
        picture: ''
        access_token: ''
        photos_data: []
    
    return {
        set: (key, value)->
            storage[key] = value
            $rootScope.$broadcast(key, value);

        push: (key, value)->
            storage[key].push value
            $rootScope.$broadcast(key, value);

        get: (key)->
            storage[key]

    }

Photowell.factory 'Overlay', ($rootScope)->
    overlay = null

    return {
        set: (value)->
            overlay = value

        get: ()->
            overlay
    }

Photowell.directive 'photoWall', ($timeout)-> 
    (scope, element, attr)-> 
        if scope.$last
            $timeout ->
                scope.container.freetile
                    animate: true  


Photowell.directive 'whenScrolled', ()->
    (scope, elm, attr)->
        scrollCheck = (evt)->
            scope.check()

        angular.element(window).bind('scroll load', scrollCheck)      

MetaCtrl = ($scope, User, Overlay)->
    Overlay.set $('.overlay') 

    FB.getLoginStatus (response)-> 
        if response.status is 'connected'
            User.set 'access_token', response.authResponse.accessToken
            
            $scope.init() 
        else
            Overlay.get().fadeIn()  

    $scope.login = ->
        FB.login (response)->
            User.set 'access_token', response.authResponse.accessToken if response.authResponse
            
            $scope.init()
        ,
        scope: 'email,user_photos,friends_photos,user_photo_video_tags,friends_photo_video_tags'

    $scope.init = ->
        FB.api '/me?fields=name,username,albums,photos,picture.type(large)&access_token=' + User.get('access_token'), (user)->
            User.set 'picture', user.picture.data.url
            User.set 'name', user.name
            User.set 'username', user.username
            User.set 'photos_data', user.photos.data

            $.each user.albums.data, (index, album)->
                FB.api '/' + album.id + '/photos?fields=name,images&access_token=' + User.get('access_token'), (response)-> 
                    User.set 'photos_data', $.merge User.get('photos_data'), response.data  


            ###
            photos = []

            $.each user.photos.data, (index, photo)->
                if photo.images[4] >= 320
                    source = photo.images[4].source
                else if photo.images[3] >= 320
                    source = photo.images[3].source
                else 
                    source = photo.images[2].source

                photos.push
                    src: source
                    src_large: photo.images[0].source
                    name: photo.name if photo.name?

            $scope.$apply ->
                $scope.name = User.get('name')   
                $scope.picture = User.get('picture')   
                $scope.username = User.get('username')   
                $.merge $scope.photos_container, photos   

            $scope.check()

            $.each user.albums.data, (index, album)->
                FB.api '/' + album.id + '/photos?fields=name,images&access_token=' + User.get('access_token'), (response)-> 
                    photos = []

                    $.each response.data, (index, image)->
                        if image.images[4] >= 320
                            source = image.images[4].source
                        else if image.images[3] >= 320
                            source = image.images[3].source
                        else 
                            source = image.images[2].source

                        photos.push
                            src: source
                            src_large: image.images[0].source
                            name: image.name if image.name?
                    
                    $scope.$apply ->
                        $.merge $scope.photos_container, photos  

                    $scope.check()

            $scope.overlay.fadeOut('slow')
            ###

    $scope.$on 'name', (events, name)->
        $scope.$apply ->
            $scope.name = name

UserCtrl = ($scope, User, Overlay)->
    $scope.container = $('.container')

    $scope.name = User.get 'name'

    $scope.username = User.get 'username'
    
    $scope.picture = User.get 'picture'

    $scope.check = ->
        if needLoad() or not hasScrollBar()
            if not $scope.hasOwnProperty('photos')
                $scope.photos = []

            photos_data = User.get('photos_data').slice 0, 20
            User.set('photos_data', User.get('photos_data').slice(20))

            photos = []

            $.each photos_data, (index, photo)->
                if photo.images[4] >= 320
                    source = photo.images[4].source
                else if photo.images[3] >= 320
                    source = photo.images[3].source
                else 
                    source = photo.images[2].source

                photos.push
                    src: source
                    src_large: photo.images[0].source
                    name: photo.name if photo.name?

            $scope.$apply ->
                $.merge $scope.photos, photos
            

            $.each User.get('photos_data').slice(0, 20), (index, img)-> 
                (new Image()).src = img.src

            ###
            $scope.$apply ->
                $.merge $scope.photos, $scope.photos_container.slice 0, 20
                $scope.photos_container = $scope.photos_container.slice 20 

            $.each $scope.photos_container.slice(0, 20), (index, img)-> 
                (new Image()).src = img.src
            ###

    ###
    $scope.init = ->
        FB.getLoginStatus (response)-> 
            if response.status is 'connected'
                User.set 'access_token', response.authResponse.accessToken
                
                $scope.initUser() 
            else
                Overlay.get().fadeIn()  
    
    $scope.login = ->
        FB.login (response)->
            User.set 'access_token', response.authResponse.accessToken if response.authResponse
            
            $scope.initUser()
        ,
        scope: 'email,user_photos,friends_photos,user_photo_video_tags,friends_photo_video_tags'
    ###

    $scope.$on 'name', (events, name)->
        $scope.$apply ->
            $scope.name = name

    $scope.$on 'username', (events, username)->
        $scope.$apply ->
            $scope.username = username

    $scope.$on 'picture', (events, picture)->
        $scope.$apply ->
            $scope.picture = picture
        ###
        $scope.$apply ->
            $scope.check()
        ###

    $scope.$on 'photos_data', (events, photos_data)->
        $scope.check()

    if User.get('photos_data').length isnt 0
        $scope.check()

    
    ###
    $scope.initUser = ->
        FB.api '/me?fields=name,username,albums,photos,picture.type(large)&access_token=' + User.get('access_token'), (user)->
            User.set 'picture', user.picture.data.url
            User.set 'name', user.name
            User.set 'username', user.username

            photos = []

            $.each user.photos.data, (index, photo)->
                if photo.images[4] >= 320
                    source = photo.images[4].source
                else if photo.images[3] >= 320
                    source = photo.images[3].source
                else 
                    source = photo.images[2].source

                photos.push
                    src: source
                    src_large: photo.images[0].source
                    name: photo.name if photo.name?

            $scope.$apply ->
                $scope.name = User.get('name')   
                $scope.picture = User.get('picture')   
                $scope.username = User.get('username')   
                $.merge $scope.photos_container, photos   

            $scope.check()

            $.each user.albums.data, (index, album)->
                FB.api '/' + album.id + '/photos?fields=name,images&access_token=' + User.get('access_token'), (response)-> 
                    photos = []

                    $.each response.data, (index, image)->
                        if image.images[4] >= 320
                            source = image.images[4].source
                        else if image.images[3] >= 320
                            source = image.images[3].source
                        else 
                            source = image.images[2].source

                        photos.push
                            src: source
                            src_large: image.images[0].source
                            name: image.name if image.name?
                    
                    $scope.$apply ->
                        $.merge $scope.photos_container, photos  

                    $scope.check()

            Elements.get('overlay').fadeOut('slow')
    $scope.check = ->
        if needLoad() or not hasScrollBar()
            if not $scope.hasOwnProperty('photos')
                $scope.photos = []

            $scope.$apply ->
                $.merge $scope.photos, $scope.photos_container.slice 0, 20
                $scope.photos_container = $scope.photos_container.slice 20 

            $.each $scope.photos_container.slice(0, 20), (index, img)-> 
                (new Image()).src = img.src
    ###

FriendsCtrl = ($scope, $location, User)->
    $scope.friends = []

    $scope.images = []
    
    $scope.images_container = []

    $scope.container = $('.container')

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

    $scope.check = ->
        if needLoad()
            $scope.$apply ->
                $.merge $scope.images, $scope.images_container.slice 0, 20
                $scope.images_container = $scope.images_container.slice 20 

            $.each $scope.images_container.slice(0, 20), (index, img)-> 
                (new Image()).src = img.src


    ###
    FB.login (response)->
        access_token = response.authResponse.accessToken if response

        FB.api '/me/friends?fields=name,username,albums,picture.type(square)&access_token=' + access_token, (response)->
            $scope.friends = []
            $scope.images = []

            $.each response.data, (index, user)->
                $scope.$apply ->
                    $scope.friends.push 
                        picture: user.picture.data.url
                        name: user.name
                        username: user.username

                return true if not user.albums?

                FB.api '/' + user.id + '/photos?fields=name,images,source&access_token=' + access_token, (response)-> 
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
                            name: image.name if image.name?
                    

                    $scope.$apply ->
                        $.merge $scope.images, images  

                return 3 > $scope.friends.length
    ,
    scope: 'email,user_photos,friends_photos,user_photo_video_tags,friends_photo_video_tags'
    ###

AlbumsCtrl = ($scope)->


PhotowellCtrl = ($scope)->
    $scope.friends = []

    $scope.images = []

    $scope.imageContainer = $('.container')

    console.log 'Photowell'

    $scope.login = ->
        FB.login (response)->
            access_token = response.authResponse.accessToken if response

            FB.api '/me/friends?fields=name,username,albums,picture.type(square)&access_token=' + access_token, (response)->
                $scope.friends = []
                $scope.images = []

                $.each response.data, (index, user)->
                    $scope.$apply ->
                        $scope.friends.push 
                            picture: user.picture.data.url
                            name: user.name
                            username: user.username

                    return true if not user.albums?

                    FB.api '/' + user.id + '/photos?fields=name,images,source&access_token=' + access_token, (response)-> 
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
                                name: image.name if image.name?
                        

                        $scope.$apply ->
                            $.merge $scope.images, images

                    ###
                    $.each user.albums.data, (index, album)->
                        FB.api '/' + album.id + '/photos?access_token=' + access_token, (response)->
                            images = []

                            $.each response.data, (index, album)->
                                images.push 
                                    src: album.source

                                return 20 > images.length

                            $scope.$apply ->
                                $.merge $scope.images, images
                    ###

                    return 3 > $scope.friends.length
        ,
        scope: 'email,user_photos,friends_photos,user_photo_video_tags,friends_photo_video_tags'
