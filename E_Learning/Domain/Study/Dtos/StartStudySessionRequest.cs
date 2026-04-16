namespace E_Learning.Domain.Study.Dtos
{
    public class StartStudySessionRequest
    {
        // "Topic" | "Favorite"
        public string SourceType { get; set; } = "Topic";

        // dùng khi SourceType = "Topic"
        public Guid? TopicId { get; set; }

        // null hoặc <= 0 thì lấy toàn bộ
        public int? TakeCount { get; set; }
    }
}
