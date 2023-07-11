const parseFieldData = (cols, data) => {
    var fieldData = new Array();
    for(var i=0;i<data.records.length;i++) {
        var recordData = data.records[i];
        var record = {'id': recordData.id};
        for(var j=0;j<cols.length;j++) {
            if(cols[j].type == 'button')continue;
            
            var fields = cols[j].fieldName.split('.');
            var value = (recordData.fields[fields[0]])?recordData.fields[fields[0]].value:'';
            for(var k=1;k<fields.length;k++) {
                if(value == null) continue;
                value = (value.fields[fields[k]])?value.fields[fields[k]].value:'';
            }
            record[cols[j].fieldName] = value;
        }
        fieldData.push(record);
    }
    return fieldData;
};
const ided = (data) => {
    var clone = [];
    for(var i=0;i<data.length;i++) {
        clone.push(structuredClone(data[i]));
        if(data[i].Id != null && data[i].id == null) {
            clone[i].id = data[i].Id;
        }
    }
    return clone;
}
export {parseFieldData, ided}