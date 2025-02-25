public without sharing class RemoveableIterator implements Iterator<SObject> {
    
    private final List<SObject> sobjects;
    Integer idx = 0;
    public RemoveableIterator(List<SObject> sobjects) {
        this.sobjects = sobjects;
    }

    public Boolean hasNext() {
        return idx<sobjects.size();
    }

    public SObject next() {
        try {
            return sobjects[idx++];
        } catch(ListException le) {
            throw new NoSuchElementException('Iterator has no more elements.');
        }
    }

    public SObject remove() {
        return sobjects.remove(idx--);
    }

    public void reset() {
        idx = 0;
    }

}