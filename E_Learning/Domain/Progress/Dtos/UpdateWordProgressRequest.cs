namespace E_Learning.Domain.Progress.Dtos
{
    public class UpdateWordProgressRequest
    {
        public bool IsCorrect { get; set; }

        // Nếu gửi lên thì ưu tiên dùng giá trị này.
        // Nếu null thì hệ thống tự tính theo rule.
        public bool? MarkLearned { get; set; }
    }
}
