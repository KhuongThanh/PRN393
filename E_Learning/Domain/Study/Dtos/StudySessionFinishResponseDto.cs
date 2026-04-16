namespace E_Learning.Domain.Study.Dtos
{
    public class StudySessionFinishResponseDto
    {
        public Guid SessionId { get; set; }

        public string SourceType { get; set; } = string.Empty;
        public string? SourceName { get; set; }

        public Guid? TopicId { get; set; }
        public string? TopicName { get; set; }

        public DateTime StartedAt { get; set; }
        public DateTime EndedAt { get; set; }

        public int TotalWords { get; set; }
        public int ReviewedCount { get; set; }
        public int RememberedCount { get; set; }
        public int NotRememberedCount { get; set; }

        public double CompletionRate { get; set; }
        public int DurationSeconds { get; set; }

        public List<StudySessionDetailItemDto> Details { get; set; } = new();
    }
}
