public class CheckCSUIDDupes implements OEETask {
    
    public String className() {
        return 'CheckCSUIDDupes';
    }

    public void runTask() {
        MergeContactCSUIDDuplicates.mergeContactCSUIDDuplicates();
    }

}