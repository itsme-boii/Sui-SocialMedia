module hackathon::Meme{
        use sui::tx_context::TxContext;
        use sui::tx_context ;
        use sui::object::{Self, ID, UID};
        use std::string::String;
        use std::vector;
        use sui::address;
        use sui::transfer;
        use sui::dynamic_object_field as ofield;
        use sui::event;
        use sui::vec_map::VecMap;
        use sui::vec_map;
        use 0x2::coin;

        public struct MemePool has key {
            id:UID,
            memeTitles:vector<String>
        }

// comments 
 // id:number;
      // title: string;
      // profilepicture: string;
      // img:string;
      // body: string;
      // like: number;
      // unFilledLike:boolean;
      // userid:string;
      // followers:number;
        public struct Meme has key,store{
            id:UID,
            owner:address,
            uname:String,
            title:String,
            image:String,
            content:String,
            likes:u64,
            liked:VecMap<address,bool>,
        } 

        public struct UserPool has key{
            id:UID
        }

        public struct User has key,store{
            id:UID,
            uname:String,
            totalPosts:u64
        }

        fun init(ctx: &mut TxContext){
            let memePool = MemePool{
                id:object::new(ctx),
                memeTitles:vector::empty()
            };
            let userPool = UserPool{
                id:object::new(ctx)
            };

            transfer::share_object(memePool);
            transfer::share_object(userPool);
        }

        entry public fun create_user(uname:String,userPool:&mut UserPool,ctx:&mut TxContext){
            let ownerAddress= tx_context::sender(ctx);
            let user = User{
                id:object::new(ctx),
                uname:uname,
                totalPosts:0
            };
            ofield::add(&mut userPool.id, uname , user);
        }

        entry public fun postMeme(
            title:String,
            image:String,
            content:String,
            uname:String,
            memePool: &mut MemePool,
            userpool: &mut UserPool,
            ctx:&mut TxContext)
            {
            let ownerAddress= tx_context::sender(ctx);
            let id1 = object::new(ctx);
            let meme1 = Meme{
                id:id1,
                owner:ownerAddress,
                uname:uname,
                title:title,
                image:image,
                content:content,
                likes:0,
                liked:vec_map::empty(),
               
            };
            ofield::add(&mut memePool.id,title,meme1);
            let memeTitles = &mut memePool.memeTitles;
            vector::push_back(memeTitles,title);
            let user=ofield::borrow_mut<String, User>(&mut userpool.id, uname);
            let totalPost = &mut user.totalPosts;
            *totalPost=*totalPost+1;
        }

        entry public fun likePost(
            title:String,
            memePool: &mut MemePool,
            ctx:&mut TxContext){

            let meme=ofield::borrow_mut<String, Meme>(&mut memePool.id, title);
            let isliked  = &mut meme.liked;
            let owner = tx_context::sender(ctx);
            if (vec_map::contains(isliked,&owner)==false){
                vec_map::insert(isliked,owner,false);
            };

            if(*vec_map::get(isliked,&owner)==false){
                vec_map::remove(isliked,&owner);
                vec_map::insert(isliked,owner,true);
              
            
                let likes = &mut meme.likes;
                *likes=*likes+1;
            
            }

            else {
                if (*vec_map::get(isliked,&owner)==true){
                    vec_map::remove(isliked,&owner);
                    vec_map::insert(isliked,owner,false);
                        let likes = &mut meme.likes;
                        if (*likes > 0){
                            *likes=*likes-1;
                        };
                }
            }
        }


    

        // entry public fun getSui(owner:address,ctx:&mut TxContext){
        //         coin::mint_and_transfer(&mut coin::TreasuryCap<SUI>,1,owner,ctx);
        // }
        }

