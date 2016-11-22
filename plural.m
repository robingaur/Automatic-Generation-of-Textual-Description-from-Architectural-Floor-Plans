function str = plural(x)
switch lower(x)
    case 'bedroom'
        y = 'bedrooms';
    case 'kitchen'
        y = 'kitchens';
    case 'hallway'
        y = 'hallways';
    case 'storage'
        y = 'storages';
    case 'garage'
        y = 'garages';
    case 'conference'
        y = 'conferences';
    case 'doublegarage'
        y = 'doublegarages';
    case 'douage'
        y = 'douages';
    case 'living room'
        y = 'living rooms';
    case 'entry'
        y = 'entries';
    case 'laundry'
        y = 'laundries';
end
str = upper(y);
end
