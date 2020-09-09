# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'csv'
require 'faker'

location = Location.first
if(!location)
  CSV.foreach(Rails.root.join('lib/locations_seeds.csv'), headers: true) do |row|
    Location.create( {
      zip: row["ZIP"], 
      lat: row["LAT"],
      long: row["LNG"]
    } ) 
  end
end

[UserInterest,UserDisability,UserCaretaker,Interest,Disability,User].each{|table| table.destroy_all}
#generate standard users
zipCodes =
[
  '19102', '19145', '19104', 
  '19106', '19114', '19115',
  '19082', '19111', '92029',
  '92071', '92101', '91911',
  '91932', '92025', '90210',
  '90005', '90010', '90012',
  '22206', '22302', '22304',
  '22305', '22306', '22307'
  
]
errors = []
zipCodes.each do |code|
  if !Location.find_by(zip: code)
    errors.push("zip #{code} needs to be removed from db")
  end
end
if !errors.empty?
  puts "----STOP: FIX THE DB--------\n"
  puts '- Remove the following entries from zipCodes in seed file: '
  errors.each{|err| puts err}
  puts '\n--------------------------'
end

#-----------users interests disabilities ---------------------------

def pic_address(size,gender,pic_id)
  base = "https://randomuser.me/api/portraits/"
  sex = gender == "male" ? "men/" : "women/"
  return base + size + "/" + sex + pic_id.to_s + '.jpg' 
end

interests = [
  'hiking', 'fishing', 'biking', 'skateboarding',
  'watching movies', 'painting', 'video games',
  'traveling', 'writing code', 'basketball', 'soccer',
  'baseball', 'golf', 'drawing', 'playing guitar',
  'listening to music', 'going to concerts', 'meeting new friends',
  'browsing the internet', 'social media', 'cooking', 'driving'
]

disabilities = [
  'autism spectrum',
  'down syndrome',
  'deafness',
  'blind',
  'asperger syndrome',
  'ms',
  'als'
]

matchGenders = [
  'male','female','any','other'
]

#assigns which gender a seed will match to depending on gender
def match(male,other)
  gender = male ? 'male' : (other ? 'other' : 'female')
  odds = rand(100)
  
  if(gender == 'male')
    if(odds <= 85)
      return 'female'
    elsif(odds <= 95)
      return 'other'
    else
      return 'any'
    end    
  
  elsif(gender == 'female')
    if(odds <= 85)
      return 'male'
    elsif(odds <= 95)
      return 'other'
    else
      return 'any'
    end
  
  else
    return ['male','female','any','other'].sample
  end
end

60.times do |n|
  if(n<10)
    caretributes =
    {
      first: Faker::Name.first_name,
      last: Faker::Name.last_name,
      email: Faker::Internet.unique.safe_email,
      password: 'care',
      validated: true,
      account_type: 'caretaker'
    }
    User.create(caretributes)
  end

  male = (n <= 31)
  other = (n > 57)  

  attributes = 
  {
    validated: true,
    account_type: 'standard',
    first: male ? Faker::Name.male_first_name : Faker::Name.female_first_name,
    last: Faker::Name.last_name,
    email: Faker::Internet.unique.safe_email,
    password: 'qweasd123',
    zip_code: zipCodes.sample,
    gender: male ? 'male' : (other ? 'other' : 'female'),
    match_gender: match(male,other),
  }
  u = User.new(attributes)
  u.pic = pic_address('',u.gender,n)
  
  myInterests = []
  rand(2..5).times do
    interest = interests.sample
    while (myInterests.include?(interest))
      interest = interests.sample
    end
    myInterests.push(interest)    
    u.interests.build(name: interest)
  end

  u.disabilities.build(name: disabilities.sample)
  u.save

  meet = ['meet','find'].sample
  looking_sentence = 
  [
    'I am looking forward to finding ',
    'I want to ' + meet,
    'I am here to ' + meet,
    'I would like to ' + meet,
    'I am hoping to ' + meet
  ].sample  
  myBio = ['Hello', 'Hola', 'Howdy', 'Hi there', 'Greetings'].sample + ', my name is ' + u.full_name 
  if(!u.interests)
    puts "user no interest #{u.full_name} + #{myInterests}"
  end
  myBio += ". My interests are #{u.interests_string}.  " + looking_sentence
  myBio += " " + (u.match_gender == 'male' ? 'a guy' : (u.match_gender == 'female' ? 'a girl' : 'someone'))
  
  myBio += ". I am here for "
  myBio +=
  [
    "finding a casual relationship!!!",
    "finding a serious relationship.",
    "finding friends!"
  ].sample

  u.bio = myBio
  u.save
end

