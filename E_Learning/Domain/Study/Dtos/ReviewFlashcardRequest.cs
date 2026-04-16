namespace E_Learning.Domain.Study.Dtos
{
    public class ReviewFlashcardRequest
    {
        public Guid WordId { get; set; }
        public bool IsRemembered { get; set; }
        public int ReviewOrder { get; set; }
    }
}
