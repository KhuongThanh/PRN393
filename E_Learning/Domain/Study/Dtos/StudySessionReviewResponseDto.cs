namespace E_Learning.Domain.Study.Dtos
{
    public class StudySessionReviewResponseDto
    {
        public Guid SessionId { get; set; }
        public Guid WordId { get; set; }
        public bool IsRemembered { get; set; }
        public int ReviewOrder { get; set; }
        public DateTime ReviewedAt { get; set; }

        public int ReviewedCount { get; set; }
        public int RemainingCount { get; set; }
        public int RememberedCount { get; set; }
        public int NotRememberedCount { get; set; }
        public int TotalWords { get; set; }
        public bool IsCompleted { get; set; }
    }
}
