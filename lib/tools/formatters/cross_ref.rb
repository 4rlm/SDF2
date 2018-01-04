### TIPS for gsubs! of Act Names Like above###
# 1) List of largest cities
# 2) List of all States (not abreviations)
# 3) List of biggest dealer groups
# 4) Capitalize each word from franchise and make space between.
# 5) capitalize all words with 2 letters (unless on commons list)
# 6) capitalize words with dash, like: Ford-Lincoln, Raleigh-Durnham.


## Temporary Call:
#Call: Migrator.new.migrate_uni_acts
#Call: Formatter.new.cross_ref_all("Ed Hicks")

module CrossRef

  # Call: Formatter.new.cross_ref_all(act_name)
  def cross_ref_all(act_name)
    act_name = cross_ref_dealers(act_name)
    act_name = cross_ref_brands(act_name)
    act_name = cross_ref_states(act_name)
    act_name = cross_ref_cities(act_name)
    return act_name
  end


  def cross_ref_dealers(act_name)
    dealers = get_dealers
    act_name = cross_ref(dealers, act_name)
    return act_name
  end

  def cross_ref_brands(act_name)
    brands = get_brands
    act_name = cross_ref(brands, act_name)
    return act_name
  end

  def cross_ref_states(act_name)
    states = get_states
    act_name = cross_ref(states, act_name)
    return act_name
  end

  def cross_ref_cities(act_name)
    cities = get_cities
    act_name = cross_ref(cities, act_name)
    return act_name
  end


  def cross_ref(list, str)
    str_down = str&.downcase
    list.each do |el|
      el_down = el&.downcase
      str&.gsub!(el_down, " #{el} ") if str_down&.include?(el_down) && !str.include?("'")
    end
    return str
  end


  def get_brands
    brands = ['Acura', 'Alfa', 'Aston', 'Audi', 'Bentley', 'Benz', 'BMW', 'Bugatti', 'Buick', 'Cadillac', 'Chevrolet', 'Chevy', 'Chrysler', 'CDJR', 'CJDR', 'Dodge', 'Ferrari', 'Fiat', 'GMC', 'Group', 'Honda', 'Hummer', 'Hyundai', 'Infiniti', 'Isuzu', 'Jaguar', 'Jeep', 'Kia', 'Lamborghini', 'Lexus', 'Lincoln', 'Lotus', 'Martin', 'Maserati', 'Mazda', 'Mclaren', 'Mercedes', 'Mini', 'Mitsubishi', 'Nissan', 'Porsche', 'Range', 'Romeo', 'Rover', 'Rolls', 'Royce', 'Saab', 'Scion', 'Smart', 'Subaru', 'Suzuki', 'Toyota', 'Volkswagen', 'Volvo', 'Autoplex', 'CJD', 'Corvette', 'Daewoo', 'Highline', 'Mercury', 'Oldsmobile', 'Plymouth', 'Pontiac', 'Saturn', 'Smart', 'Superstore', 'Used']
    return brands
  end

  def get_states
    states = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming']
    return states
  end

  def get_state_codes
    state_codes = ['AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MS', 'MT', 'NC', 'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', 'NY', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VA', 'VT', 'WA', 'WI', 'WV', 'WY', 'NE', 'NW', 'SE', 'SW']
    return state_codes
  end

  def get_dealers
    dealers = ["&", "ABC", "Action", "Acton", "Airpark", "Alexer", "American", "Ancira", "Aristocrat", "Arrowhead", "Aubrey", 'AutoNation', "Automall", "Automotive", "Autoplex", "Beachwood", "Bed", "Bergstrom", "Best", "Bethesda", "Bianchi", "Billy", "Blaise", "Bob", "Bommarito", "borough", "Braintree", "Braman", "Branch", "Brickell", "Bridgewater", "Brook", "Cable", "Camelback", "Capitol", "Cardinale", "Cars", "Case", "Catena", "Catonsville", "Central", "Chambers", "Chantilly", "Chapman", "Chler", "Church", "Classic", "Commonwealth", "Community", "Company", "Corner", "country", "Courtesy", "Credit", "Crest", "Crevier", "Criswell", "Dade", "Dahmer", "Dale", "DARCARS", "Darrell", "Dave", "David", "Dealership", "DeFouw", "Delta", "Desoto", "Direct", "Downtown", "Earnhardt", "Edison", "ElCerrito", "Enterprises", "Fairfax", "Fernez", "Fitzgerald", "Flagship", "Fletcher", "ForthWorth", "Fox", "Fred", "Freedom", "Freehold", "Freeway", "Frontier", "Ft", "Future", "Galloway", "Gateway", "Germain", "Gillman", "Gold", "Gordon", "Greenway", "Greenwich", "Gwinnett", "Haik", "Hare", "Harold", "Hendrick", "Hendrickson", "Henry", "Herb", "Hill", "Hills", "Holman", "Houston", "Hudson", "Huffines", "Husker", "Imports", "Jack", "Jeff", "Jim", "Jimmie", "Joe", "Jones", "Jr", "Kenny", "Kings", "Koons", "Labonte", "Laird", "Lane", "Lanham", "Larchmont", "Larry", "Laurel", "Liberty", "Lindon", "Lmark", "Mac", "Mall", "Mark", "Markley", "Marsh", "Maus", "Maxton", "McCombs", "Merriam", "Michael", "Midway", "Mike", "Mile", "Miller", "minster", "Mitchell", "Monmouth", "Morse", "Motorcars", "Motorhomes", "Motorwerks", "Mullinax", "Naples", "Natick", "Navarre", "Niello", "Noller", "North", "Northlake", "Northridge", "Northside", "Olmsted", "Online", "Ourisman", "Penske", "Performance", "Peter", "Phil", "Long", "Piercey", "Pike", "Pinnacle", "Palace", "Place", "Plaza", "Pointe", "Prestige", "Pros", "Reliable", "Patrick", "Rightway", "Rodeo", "Rosner", "Rusnak", "Russell", "Sales", "Saver", "Sawgrass", "Seekonk", "Serra", "Shaw", "Shopper", "Showcase", "Silver", "Skillman", "South", "Southpoint", "Southway", "Southwest", "Sports", "Spring", "Stevens", "Stonebriar", "Strickl", "Suburban", "Sudbury", "SunlPark", "Super", "Sweeney", "Tenafly", "Terry", "Towne", "Traverse", "Trophy", "Trucks", "Trucks", "Turnersville", "Tysons", "United", "Universal", "Vergriff", "Victory", "Villa", "Village", "Voss", "Walker", "Waltrip", "Wilde", "Winton", "Wolfchase", "Woodbridge", "World", "Zeigler", "Chapman’s", "Earnhardt’s", "Tyson’s", "Wilson’s", "Magnussen’s", 'Buy']
  end

  def get_cities
    cities = ["Abilene", "Akron", "Alameda", "Albany", "Albuquerque", "Alexandria", "Alhambra", "Aliso", "Allen", "Allentown", "Allis", "Alpharetta", "Altamonte", "Alto", "Altoona", "Amarillo", "Amboy", "Ames", "Anaheim", "Anchorage", "Anderson", "Angelo", "Ankeny", "Annapolis", "Antioch", "Antonio", "Apache", "Apex", "Apopka", "Apple", "Appleton", "Arbor", "Arcadia", "Arlington", "Arrow", "Arthur", "Arvada", "Asheville", "Athens", "Atlanta", "Atlantic", "Attleboro", "Auburn", "Augusta", "Aurora", "Austin", "Avondale", "Azusa", "Bakersfield", "Baldwin", "Baltimore", "Barbara", "Barnstable", "Barre", "Bartlett", "Baton", "Battle", "Bay", "Bayonne", "Baytown", "Beach", "Beaumont", "Beavercreek", "Beaverton", "Bedford", "Bell", "Belleville", "Bellevue", "Bellflower", "Bellingham", "Bend", "Bentonville", "Berkeley", "Berlin", "Bernardino", "Berwyn", "Bethlehem", "Beverly", "Bibb", "Billings", "Biloxi", "Binghamton", "Birmingham", "Bismarck", "Blacksburg", "Blaine", "Bloomington", "Blue", "Bluff", "Bluffs", "Boca", "Boise", "Bolingbrook", "Bonita", "Bossier", "Boston", "Bothell", "Boulder", "Bountiful", "Bowie", "Bowling", "Boynton", "Bozeman", "Bradenton", "Braunfels", "Brea", "Bremerton", "Brentwood", "Bridgeport", "Brighton", "Bristol", "Britain", "Brockton", "Broken", "Brookhaven", "Brooklyn", "Broomfield", "Brownsville", "Bruno", "Brunswick", "Bryan", "Buckeye", "Buena", "Buenaventura", "Buffalo", "Buffalo", "Bullhead", "Burbank", "Burien", "Burleson", "Burlington", "Burnsville", "Cajon", "Caldwell", "Calexico", "Camarillo", "Cambridge", "Camden", "Campbell", "Canton", "Cape", "Carlsbad", "Carmel", "Carol", "Carpentersville", "Carrollton", "Carson", "Cary", "Casa", "Casper", "Castle", "Cathedral", "Cedar", "Cedar", "Centennial", "Centro", "Ceres", "Cerritos", "Champaign", "Chandler", "Chapel", "Charles", "Charleston", "Charlotte", "Charlottesville", "Chattanooga", "Chelsea", "Chesapeake", "Chesterfield", "Cheyenne", "Chico", "Chicopee", "Chino", "Chino", "Christi", "Chula", "Cicero", "Cincinnati", "Citrus", "City", "Clair", "Claire", "Clara", "Clarita", "Clarke", "Clarksville", "Clearwater", "Clemente", "Cleveland", "Cleveland", "Clifton", "Cloud", "Clovis", "Coachella", "Coast", "Coconut", "Coeur", "College", "Collierville", "Collins", "Colony", "Colorado", "Colton", "Columbia", "Columbus", "Commerce", "Compton", "Concord", "Conroe", "Conway", "Coon", "Coppell", "Coral", "Coral", "Cordova", "Corners", "Corona", "Corpus", "Corvallis", "Costa", "Council", "County", "Covina", "Covington", "Cranston", "Creek", "Crosse", "Cruces", "Cruz", "Crystal", "Cucamonga", "Culver", "Cupertino", "Cutler", "Cuyahoga", "Cypress", "Dallas", "Daly", "Danbury", "Danville", "Davenport", "Davidson", "Davie", "Davis", "Dayton", "Daytona", "Dearborn", "Dearborn", "Decatur", "Deerfield", "DeKalb", "Delano", "Delaware", "Delray", "Deltona", "Denton", "Denver", "Des", "Desert", "DeSoto", "Detroit", "Diamond", "Diego", "Doral", "Dothan", "Downers", "Downey", "Draper", "Dublin", "Dubuque", "Duluth", "Duncanville", "Dunwoody", "Durham", "Eagan", "Eastvale", "Eau", "Eden", "Edina", "Edinburg", "Edmond", "Edmonds", "Elgin", "Elizabeth", "Elk", "Elkhart", "Elm", "Elmhurst", "Elsinore", "Elyria", "Encinitas", "Enid", "Erie", "Escondido", "Estates", "Euclid", "Eugene", "Euless", "Evanston", "Evansville", "Everett", "Fairfield", "Fall", "Falls", "Fargo", "Farmington", "Farmington", "Fayette", "Fayetteville", "Federal", "Findlay", "Fishers", "Fitchburg", "Flagstaff", "Flint", "Florence", "Florissant", "Flower", "Folsom", "Fond", "Fontana", "Forest", "Fork", "Forks", "Fountain", "Francisco", "Franklin", "Frederick", "Freeport", "Fremont", "Fresno", "Friendswood", "Frisco", "Fullerton", "Gables", "Gabriel", "Gainesville", "Gaithersburg", "Galveston", "Garden", "Gardena", "Gardens", "Garland", "Gary", "Gastonia", "Gate", "George", "Georgetown", "Germantown", "Gilbert", "Gilroy", "Girardeau", "Glendale", "Glendora", "Glenview", "Goodyear", "Goose", "Grand", "Grande", "Grapevine", "Great", "Greeley", "Green", "Greenacres", "Greensboro", "Greenville", "Greenwood", "Gresham", "Grove", "Gulfport", "Habra", "Hackensack", "Hagerstown", "Hallandale", "Haltom", "Hamilton", "Hammond", "Hampton", "Hanford", "Harlingen", "Harrisburg", "Harrisonburg", "Hartford", "Hattiesburg", "Haute", "Havasu", "Haven", "Haverhill", "Hawthorne", "Hayward", "Head", "Heights", "Hemet", "Hempstead", "Henderson", "Hendersonville", "Hesperia", "Hialeah", "Hickory", "High", "Highland", "Hillsboro", "Hilton", "Hoboken", "Hoffman", "Hollywood", "Holyoke", "Homestead", "Honolulu", "Hoover", "Huntersville", "Huntington", "Huntington", "Huntsville", "Hurst", "Hutchinson", "Idaho", "Independence", "Indian", "Indianapolis", "Indio", "Inglewood", "Iowa", "Irvine", "Irving", "Island", "Jacinto", "Jackson", "Jacksonville", "Janesville", "Jefferson", "Jefferson", "Jeffersonville", "Jersey", "Johns", "Johnson", "Joliet", "Jonesboro", "Joplin", "Jordan", "Jose", "Joseph", "Junction", "Jupiter", "Jurupa", "Kalamazoo", "Kannapolis", "Kansas", "Kearny", "Keizer", "Keller", "Kenner", "Kennewick", "Kenosha", "Kent", "Kentwood", "Kettering", "Killeen", "Kingsport", "Kirkland", "Kissimmee", "Knoxville", "Kokomo", "Kyle", "Lacey", "Lafayette", "Laguna", "Lake", "Lakeland", "Lakeville", "Lakewood", "Lancaster", "Lansing", "Laredo", "Largo", "Lauderdale", "Lauderhill", "Lawn", "Lawrence", "Lawton", "Layton", "League", "Leander", "Leandro", "Leesburg", "Lehi", "Lenexa", "Leominster", "Lewisville", "Lexington", "Lincoln", "Linda", "Linden", "Little", "Littleton", "Livermore", "Livonia", "Lodi", "Logan", "Lombard", "Lompoc", "Long", "Longmont", "Longview", "Lorain", "Louis", "Louis", "Louisville", "Loveland", "Lowell", "Lubbock", "Lucie", "LuisObispo", "Lynchburg", "Lynn", "Lynwood", "Macon", "Madera", "Madison", "Malden", "Manassas", "Manchester", "Manhattan", "Mankato", "Mansfield", "Manteca", "Maple", "Maplewood", "Marana", "Marcos", "Margarita", "Margate", "Maria", "Maricopa", "Marietta", "Marion", "Marlborough", "Martinez", "Marysville", "Mateo", "McAllen", "McKinney", "Medford", "Melbourne", "Memphis", "Menifee", "Mentor", "Merced", "Meriden", "Meridian", "Mesa", "Mesquite", "Methuen", "Miami", "Miami", "Middletown", "Midland", "Midwest", "Milford", "Milpitas", "Milton", "Milwaukee", "Minneapolis", "Minnetonka", "Minot", "Mirada", "Miramar", "Mishawaka", "Mission", "Missoula", "Missouri", "Mobile", "Modesto", "Moines", "Moline", "Monica", "Monroe", "Montclair", "Monte", "Montebello", "Monterey", "Montgomery", "Moore", "Moorhead", "Moreno", "Morgan", "Mound", "Mount", "Mountain", "Muncie", "Murfreesboro", "Murray", "Murrieta", "Muskegon", "Muskogee", "Myers", "Nampa", "Napa", "Naperville", "Nashua", "Nashville", "National", "New", "Newark", "Newport", "News", "Newton", "Niagara", "Niguel", "Noblesville", "Norfolk", "Normal", "Norman", "Northglenn", "Norwalk", "Norwich", "Novato", "Novi", "Oak", "Oakland", "Oakley", "Oaks", "Ocala", "Oceanside", "Ocoee", "Odessa", "Ogden", "Oklahoma", "Olathe", "Olympia", "Omaha", "Ontario", "Orange", "Orem", "Orland", "Orlando", "Orleans", "Ormond", "Oshkosh", "Oswego", "Overland", "Oviedo", "Owensboro", "Oxnard", "Pacifica", "Palatine", "Palm", "Palmdale", "Palo", "Palos", "Paramount", "Parker", "Parma", "Pasadena", "Pasco", "Paso", "Passaic", "Paterson", "Paul", "Pawtucket", "Peabody", "Peachtree", "Pearland", "Pembroke", "Pensacola", "Peoria", "Perris", "Perth", "Petaluma", "Peters", "Petersburg", "Pflugerville", "Pharr", "Pico", "Pierce", "Pine", "Pinellas", "Pines", "Pittsburg", "Pittsburgh", "Pittsfield", "Placentia", "Plaines", "Plainfield", "Plains", "Plano", "Plantation", "Pleasant", "Pleasanton", "Plymouth", "Pocatello", "Point", "Pomona", "Pompano", "Pontiac", "Portage", "Porterville", "Portland", "Portsmouth", "Poway", "Prairie", "Prescott", "Prescott", "Prospect", "Providence", "Provo", "Pueblo", "Puente", "Puyallup", "Quincy", "Quinta", "Racine", "Rafael", "Raleigh", "Ramon", "Rancho", "Rapid", "Rapids", "Raton", "Reading", "Redding", "Redlands", "Redmond", "Redondo", "Redwood", "Reno", "Renton", "Revere", "Rialto", "Richardson", "Richland", "Richland", "Richmond", "Rio", "River", "Rivera", "Riverside", "Riverton", "Roanoke", "Robins", "Rochelle", "Rochester", "Rochester", "Rock", "Rockford", "Rocklin", "Rockville", "Rockwall", "Rocky", "Rogers", "Rohnert", "Romeoville", "Rosa", "Rosemead", "Roseville", "Roswell", "Rouge", "Round", "Rowlett", "Roy", "Royal", "Sacramento", "Saginaw", "Salem", "Salina", "Salinas", "Salt", "Sammamish", "Sandy", "Sanford", "Santa", "Santee", "Sarasota", "Savannah", "Sayreville", "Schaumburg", "Schenectady", "Schertz", "Scottsdale", "Scranton", "Seattle", "Shakopee", "Shawnee", "Sheboygan", "Shelton", "Sherman", "Shoreline", "Shores", "Shreveport", "Sierra", "Simi", "Sioux", "Skokie", "Smith", "Smyrna", "Somerville", "Southaven", "Southfield", "Spanish", "Sparks", "Spokane", "Spokane", "Springdale", "Springfield", "Springs", "Stamford", "Stanton", "State", "Station", "Sterling", "Stillwater", "Stockton", "Stream", "Streamwood", "Strongsville", "Suffolk", "Sugar", "Summerville", "Summit", "Sumter", "Sunnyvale", "Sunrise", "Surprise", "Syracuse", "Tacoma", "Tallahassee", "Tamarac", "Tampa", "Taunton", "Taylor", "Taylorsville", "Temecula", "Tempe", "Temple", "Terre", "Texas", "The", "Thornton", "Thousand", "Tigard", "Tinley", "Titusville", "Toledo", "Topeka", "Torrance", "Tracy", "Trail", "Trenton", "Troy", "Tucson", "Tulare", "Tulsa", "Tupelo", "Turlock", "Tuscaloosa", "Tustin", "Twin", "Tyler", "Union", "Upland", "Urbana", "Urbandale", "Utica", "Vacaville", "Valdosta", "Vallejo", "Valley", "Vancouver", "Vegas", "Ventura", "Verdes", "Vernon", "Victoria", "Victorville", "Viejo", "View", "Vineland", "Virginia", "Visalia", "Vista", "Waco", "Wake", "Walnut", "Waltham", "Warner", "Warren", "Warwick", "Washington", "Waterbury", "Waterloo", "Watsonville", "Waukegan", "Waukesha", "Wausau", "Wauwatosa", "Wayne", "Wellington", "Weslaco", "Westerville", "Westfield", "Westland", "Westminster", "Weston", "Weymouth", "Wheaton", "Wheeling", "White", "Whittier", "Wichita", "Wichita", "Wilkes", "Wilmington", "Wilson", "Winston", "Winter", "Woburn", "Woodbury", "Woodland", "Woonsocket", "Worcester", "Worth", "Wylie", "Wyoming", "Yakima", "Yonkers", "Yorba", "York", "Youngstown", "Yuba", "Yucaipa", "Yuma"]
    return cities
  end


end
