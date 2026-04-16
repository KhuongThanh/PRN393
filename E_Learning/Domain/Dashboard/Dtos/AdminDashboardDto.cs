namespace E_Learning.Domain.Dashboard.Dtos
{
    public class AdminDashboardDto
    {
        public int TotalUsers { get; set; }
        public int TotalTopics { get; set; }
        public int TotalWords { get; set; }
        public int TotalQuizzes { get; set; }
        public int TotalFlashcardSessions { get; set; }
        public int TotalQuizAttempts { get; set; }
    }
}
