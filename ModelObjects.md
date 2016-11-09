class User {
user_id : String 
username  : String
email : String 
password : String
firstName : String
lastName : String
teams : List<Team>
points : Map<Team, Points(Int)>
skills : Map<skillName(String), points (Int)>
profileImage : Photo
}

class Team {
team_id : String
name : String 
adminUser : User
users : List<User>
rewards : List<Reward>
}

class Company {
company_id : String
name : String
teams : List<Team>
categories : Map<name(String), Category>
}

class Message {
team : Team
message_id : String
timestamp : TimeStamp
from : User
to : User 
points : Int
message : String 
categories : List<Category>
}


class Category {
name : String 
points : Map<User, Points>
company : Company
}

class Reward {
reward_id : String    
name : String
points : Int
claimed : Bool
}
