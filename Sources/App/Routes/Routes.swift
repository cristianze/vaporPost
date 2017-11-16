import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        get("helloGet", Int.parameter, String.parameter) { req in
            var json = JSON()
            let bottles = try req.parameters.next(Int.self)
            let name = try req.parameters.next(String.self)
            
            try json.set("message", "bottels left = \(bottles - 1)")
            try json.set("name of bottle", "\(name)")
            return json
        }
        
        post("helloPost") { request in
            guard let content = request.data["content"]?.string else {
                return try JSON(node: [
                    "message:": "parametro incorrecto, revise!"
                    ])
                throw Abort.badRequest
            }
            
            let littlePost = Post(content: content)
            try littlePost.save()
            
            return try JSON(node: [
                "message": "Post creado correctamente. Post: \(content)!"
                ])
        }
        
        get("returnPost") { request in
            var postsArray: [Post] = []
            for post in try Post.all(){
                postsArray.append(post)
            }
            return try JSON(node: [
                "posts": postsArray
                ])
        }
        
        get("returnPostById", Int.parameter){ request in
            let idOfPost = try request.parameters.next(Int.self)
            
            guard let postToReturn = try Post.find(idOfPost) else {
                throw Abort.notFound
            }
            
            return try JSON(node: [
                "postByID": postToReturn
                ])
        }
        
        try resource("posts", PostController.self)
    }
}
