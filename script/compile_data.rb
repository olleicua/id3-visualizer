require 'json'
def range_to_string(range)
  "#{range.min}-#{range.max}"
end

def raw_from_file(file)
  open(file, 'r').map { |line| line.split(',').map(&:strip) }
end

def classes_for(raw_data, index)
  data = raw_data\
         .reject { |d| d[index] == '?' }\
         .map { |d| d[index].to_i }
  min = data.min
  max = data.min
  mid = min + ((max - min) / 2)
  [min .. mid, (mid + 1) .. max]
end

def prepare_data(attributes, raw_data)
  raw_data.map do |raw_d|
    d = {}
    attributes.each_with_index do |attribute, index|
      val = raw_d[index]
      if attribute[:classes][0].is_a? Range
        range = attribute[:classes].detect do |klass|
          klass.include? val
        end || attribute[:classes].last
        val = range_to_string range
      end
      d[attribute[:name]] = val
    end
    d
  end
end

def prepare_attributes(attributes)
  attributes.tap do |atts|
    atts.each do |att|
      att[:classes] = att[:classes].map do |klass|
        if klass.is_a? Range
          range_to_string(klass)
        else
          klass
        end
      end
    end
  end
end

training_raw =  raw_from_file 'app/data/adult.test.txt'
test_raw =  raw_from_file 'app/data/adult.data.txt'
all_raw = training_raw + test_raw

attributes = [
  {
    name: 'age',
    classes: classes_for(all_raw, 0)
  }, {
    name: 'workclass',
    classes: %w[ Private Self-emp-not-inc Self-emp-inc Federal-gov Local-gov State-gov Without-pay Never-worked ]
  }, {
    name: 'fnlwgt',
    classes: classes_for(all_raw, 2)
  }, {
    name: 'education',
    classes: %w[ Bachelors Some-college 11th HS-grad Prof-school Assoc-acdm Assoc-voc 9th 7th-8th 12th Masters 1st-4th 10th Doctorate 5th-6th Preschool ]
  }, {
    name: 'education-num',
    classes: classes_for(all_raw, 4)
  }, {
    name: 'marital-status',
    classes: %w[ Married-civ-spouse Divorced Never-married Separated Widowed Married-spouse-absent Married-AF-spouse ]
  }, {
    name: 'occupation',
    classes: %w[ Tech-support Craft-repair Other-service Sales Exec-managerial Prof-specialty Handlers-cleaners Machine-op-inspct Adm-clerical Farming-fishing Transport-moving Priv-house-serv Protective-serv Armed-Forces ]
  }, {
    name: 'relationship',
    classes: %w[ Wife Own-child Husband Not-in-family Other-relative Unmarried ]
  }, {
    name: 'race',
    classes: %w[ White Asian-Pac-Islander Amer-Indian-Eskimo Other Black ]
  }, {
    name: 'sex',
    classes: %w[ Female Male ]
  }, {
    name: 'capital-gain',
    classes: classes_for(all_raw, 10)
  }, {
    name: 'capital-loss',
    classes: classes_for(all_raw, 11)
  }, {
    name: 'hours-per-week',
    classes: classes_for(all_raw, 12)
  }, {
    name: 'native-country',
    classes: %w[ United-States Cambodia England Puerto-Rico Canada Germany Outlying-US(Guam-USVI-etc) India Japan Greece South China Cuba Iran Honduras Philippines Italy Poland Jamaica Vietnam Mexico Portugal Ireland France Dominican-Republic Laos Ecuador Taiwan Haiti Columbia Hungary Guatemala Nicaragua Scotland Thailand Yugoslavia El-Salvador Trinadad&Tobago Peru Hong Holand-Netherlands ]
  }, {
    name: 'income',
    classes: %w[ <=50K >50K ]
  }
]

data = {
  training_data: prepare_data(attributes, training_raw),
  test_data: prepare_data(attributes, test_raw),
  attributes: prepare_attributes(attributes)
}

open('app/data/adult.json', 'w').write JSON.dump(data)