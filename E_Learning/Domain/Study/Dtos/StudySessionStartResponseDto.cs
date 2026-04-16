namespace E_Learning.Domain.Study.Dtos
{
    public class StudySessionStartResponseDto
    {
        public Guid SessionId { get; set; }

        public string SourceType { get; set; } = string.Empty;
        public string? SourceName { get; set; }

        public Guid? TopicId { get; set; }
        public string? TopicName { get; set; }

        public string SessionType { get; set; } = "Flashcard";
        public DateTime StartedAt { get; set; }
        public int TotalWords { get; set; }

        public List<FlashcardWordDto> Words { get; set; } = new();
    }
}