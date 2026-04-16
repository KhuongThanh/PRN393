namespace E_Learning.Domain.Study.Dtos
{
    public class StudySessionDetailItemDto
    {
        public Guid SessionDetailId { get; set; }
        public Guid WordId { get; set; }
        public string WordText { get; set; } = string.Empty;
        public string Meaning { get; set; } = string.Empty;
        public bool IsRemembered { get; set; }
        public int ReviewOrder { get; set; }
        public DateTime ReviewedAt { get; set; }
    }
}
