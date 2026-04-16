using E_Learning.Domain.Study.Dtos;

namespace E_Learning.Domain.Study.Interface
{
    public interface IStudySessionService
    {
        Task<StudySessionStartResponseDto> StartSessionAsync(Guid userId, StartStudySessionRequest request);
        Task<StudySessionReviewResponseDto> ReviewWordAsync(Guid userId, Guid sessionId, ReviewFlashcardRequest request);
        Task<StudySessionFinishResponseDto> FinishSessionAsync(Guid userId, Guid sessionId);
        Task<List<StudySessionHistoryItemDto>> GetHistoryAsync(Guid userId);
        Task<StudySessionDetailResponseDto> GetSessionDetailAsync(Guid userId, Guid sessionId);
    }
}
