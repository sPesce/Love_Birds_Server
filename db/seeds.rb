require 'csv'
require 'faker'

seedInput = ['full-destructive',1500]

#TODO: convert this to boolean
seedNumber = {
  #'only-zips' => 0, not possible
  'full-destructive' => 1,
  'only-users' => 2
}
seed = seedNumber[seedInput[0]]
N = seedInput[1]
puts "seed option #{seed} user size: #{seedInput[1]}"


tables = 
[
  UserInterest,
  UserDisability,
  UserCaretaker,
  Interest,
  Disability,
  Match,
  User
]
destroy_bar_size = tables.length + ((seed == 2 && Location.count < 10000) ? 0 : 10)
destroy_bar = TTY::ProgressBar.new("Destroying Tables: [:bar]", total: destroy_bar_size)

tables.each do |table| 
  table.destroy_all
  destroy_bar.advance
end
if(seed != 2)
  Location.all.select(:id).find_in_batches(batch_size: Location.count/10) do |ids|
    Location.where(id: ids).delete_all
    destroy_bar.advance
  end 
  puts "finished destroying locations"
end


if(seed != 2)
  puts "seeding locations, this may take a minute...\n\n"
  Location.destroy_all
  zipBar = TTY::ProgressBar.new("Seeding Locations: [:bar]", total: 9)
  (1..9).each do |n|
    CSV.foreach(Rails.root.join("lib/locations_seeds_#{n}.csv"), headers: true) do |row|
        Location.create( {
          zip: row["ZIP"], 
          lat: row["LAT"],
          long: row["LNG"]
        } )   
    end
    zipBar.advance  
  end
  puts "\nfinished seeding locations"
else
  puts 'skipping seeding locations because it takes forever and its never edited'
end

#generate standard users
zipCodes =
[
  '19102', '19145', '19104', 
  '19106', '19114', '19115',
  '19082', '19111',   
  '22206', '22302', '22304',
  '22305', '22306', '22307'
  
]
puts "checking zip code errors..."
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
else
puts "...everything looks fine"
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
if seed > 0

  careBar = TTY::ProgressBar.new("Seeding Caretakers [:bar]", total: 40)
  10.times do |n|
    caretributes =
      {
        first: Faker::Name.unique.first_name,
        last: Faker::Name.last_name,
        email: Faker::Internet.unique.safe_email,
        password: 'care',
        validated: true,
        account_type: 'caretaker'
      }
      u = User.new(caretributes)
      u.email = u.first + '@gmail.com'
      u.save
      careBar.advance(4) 
  end
  
  barSize = N >= 40 ? 40 : N
  usrBar = TTY::ProgressBar.new("Seeding Users [:bar]", total: barSize)
  
  N.times do |n|
    usrBar.advance if (n % (N / barSize) == 0)
    
    male = (n <= N/2)
    other = (n > (N - 10))  

    attributes = 
    {
      validated: true,
      account_type: 'standard',
      first: male ? Faker::Name.unique.male_first_name : Faker::Name.female_first_name,
      last: Faker::Name.last_name,
      email: Faker::Internet.unique.safe_email,
      password: 'qweasd123',
      zip_code: zipCodes.sample,
      gender: male ? 'male' : (other ? 'other' : 'female'),
      match_gender: match(male,other),
    }
    u = User.new(attributes)
    u.pic = pic_address('',u.gender,[0..100].sample)
    u.email = u.first + '@gmail.com'
    u.save
    
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
    if(!u.location)
      u.destroy
      puts "#{n}th record created was bad and needs to be destroyed!"
    end
    if (n % 5) 
      print '-'
    end
  end
  print '---------->'

  puts 'seeding matches'
  reciever = User.all[15]
  senders = reciever.get_closest[1..10]

  senders.each do |s|
    Match.create(user_id: s.id,
    matched_user_id: reciever.id,
    sender_status: 2,
    reciever_status: 0)
  end
  puts "15th user got 10 match requests from his closest potential matches"
end

puts '-------------------------------------------------'
puts '-----------SEEDING-------Successfull-------------'
puts '-------------------------------------------------'
