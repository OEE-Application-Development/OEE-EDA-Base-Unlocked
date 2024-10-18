global class ConvertResult {

    global List<Contact> success;
    global List<Contact> failed;

    global ConvertResult(List<Contact> success, List<Contact> failed) {
        this.success = success;
        this.failed = failed;
    }
    
}