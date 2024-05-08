module hackathon::SocialMeal{
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
        use sui::clock;
        use sui::sui::SUI;
        use sui::coin::Coin;
        use sui::balance::{Self, Balance};



        public struct OrganizersPool has key{
            id:UID,
        }
        public struct OrganiserIdentity has store,key{
            id:UID,
            suName:String,
            name:String,
            passOutSchool:String,
            balance: Balance<SUI>
        }

        public struct UserIPool has key{
            id:UID,
        }

       
        public struct UserIdentity has store,key{
            id:UID,
            suName:String,
            name:String,
            passOutSchool:String,
            verificationPassedPercent:u64,
            trustScore:u64,
        }

        public struct EventPool has key,store{
            id:UID,
        }
        
        public struct Event has key,store{
            id:UID,
            description:String,
            city:String,
            venue:String,
            cost:u64,
            organiser:String,
            arrayPrice:vector<u64>,
            markedCompletedCount:u64,
            totalNumberOfPeopleJoins:u64,
        }

         public struct EventDone has key{
            id:UID,
            doneEvent:vector<Event>
        }


        fun init(ctx:&mut TxContext){
            let eventPool = EventPool{
                id:object::new(ctx),
            };
            let organiserPool = OrganizersPool{
                id:object::new(ctx),
            };
            let userIPool = UserIPool{
                id:object::new(ctx),
            };
            let eventDone=EventDone{
                id:object::new(ctx),
                doneEvent:vector::empty()
            };

            transfer::share_object(eventPool);
            transfer::share_object(organiserPool);
            transfer::share_object(userIPool);
            transfer::share_object(eventDone);
        }

        entry public fun becomeOrganiser(
            name:String,
            suName:String,
            passOutSchool:String,
            organiserPool:&mut OrganizersPool,
            ctx:&mut TxContext
            ){
                let organiser = OrganiserIdentity{
                    id:object::new(ctx),
                    suName:suName,
                    name:name,
                    passOutSchool:passOutSchool,
                    balance: balance::zero()
                };
                ofield::add(&mut organiserPool.id,suName,organiser);
            }
        
        entry public fun createUser(
            suName:String,
            name:String,
            passOutSchool:String,
            userIPool:&mut UserIPool,
            ctx:&mut TxContext
        ){
            let user = UserIdentity{
                id:object::new(ctx),
                suName:suName,
                name:name,
                passOutSchool:passOutSchool,
                verificationPassedPercent:0,
                trustScore:0,
            };
            ofield::add(&mut userIPool.id,suName,user);
        }

        entry public fun verifyUser(
            suName:String,
            isIt:bool,
            userIPool:&mut UserIPool,
            ctx:&mut TxContext,
        ){
            let user = ofield::borrow_mut<String, UserIdentity>(&mut userIPool.id,suName);
            let verificationPassedPercent = &mut user.verificationPassedPercent;
            let trustScore = &mut user.trustScore;
            if (isIt==false){
                if(*verificationPassedPercent>0){
                    *verificationPassedPercent=*verificationPassedPercent-1;
                }
            }
            else if(isIt==true){
                *verificationPassedPercent=*verificationPassedPercent+5

            };
            if(*verificationPassedPercent>30){
                *trustScore=*trustScore+5;
            }

        }

        entry public fun createEvent(
            description:String,
            city:String,
            venue:String,
            cost:u64,
            suName:String,
            eventPool:&mut EventPool,
            totalNumberOfPeopleJoins:u64,
            ctx:&mut TxContext,
        ){
            let event = Event{
            id:object::new(ctx),
            description:description,
            city:city,
            venue:venue,
            cost:cost,
            organiser:suName,
            arrayPrice:vector::empty(),
            markedCompletedCount:0,
            totalNumberOfPeopleJoins:totalNumberOfPeopleJoins,
            };
            ofield::add(&mut eventPool.id,suName,event);
        }

        public entry fun markComplete(
            suName:String,
            eventPool:&mut EventPool,
            eventDone:&mut EventDone,
            organiserPool:&mut OrganizersPool,
            payment: &mut Coin<SUI>,
            ctx:&mut TxContext,
        ){

            let event = ofield::borrow_mut<String,Event>(&mut eventPool.id,suName);
            let cost = &mut event.cost;
            let markedCompletedCount = &mut event.markedCompletedCount;
            *markedCompletedCount=*markedCompletedCount+1;
            let totalNumberOfPeopleJoins = &mut event.totalNumberOfPeopleJoins;
            let organiser = ofield::borrow_mut<String,OrganiserIdentity>(&mut organiserPool.id,suName);
            if(*markedCompletedCount==((70*(*totalNumberOfPeopleJoins))/100)){
            let paid = payment.balance_mut().split(*cost);
            organiser.balance.join(paid);
            let event = ofield::remove<String,Event>(&mut eventPool.id,suName);
            let eventDone = &mut eventDone.doneEvent;
            vector::push_back(eventDone,event);}

        }

        public entry fun bugetSelection(
            suName:String,
            eventPool:&mut EventPool,
            bugget:u64,
            ctx:&mut TxContext,
        ){
            let event = ofield::borrow_mut<String,Event>(&mut eventPool.id,suName);
            let cost = &mut event.cost;
            let array = &mut event.arrayPrice;
            if (vector::length(array)<5){
            vector::push_back(array,bugget);
            }
            else {
                let mut sum =0;
                let mut i=0;
                while(i < 5){
                    sum=sum+array[i];
                    i=i+1;
                };
                *cost=sum/5;
            }
            


        }

      


















}