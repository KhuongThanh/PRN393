using E_Learning.Data;
using E_Learning.Domain.Admin.Options.Dtos;
using E_Learning.Domain.Admin.Options.Interface;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Admin.Options.Services
{
    public class AdminOptionService : IAdminOptionService
    {
        private readonly AppDbContext _context;

        public AdminOptionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<AdminOptionListItemDto>> GetByQuestionAsync(Guid questionId)
        {
            var questionExists = await _context.QuizQuestions
                .AnyAsync(x => x.QuestionId == questionId);

            if (!questionExists)
                throw new KeyNotFoundException("Question not found.");

            return await _context.QuizQuestionOptions
                .Where(x => x.QuestionId == questionId)
                .OrderBy(x => x.DisplayOrder)
                .Select(x => new AdminOptionListItemDto
                {
                    OptionId = x.OptionId,
                    QuestionId = x.QuestionId,
                    OptionText = x.OptionText,
                    IsCorrect = x.IsCorrect,
                    DisplayOrder = x.DisplayOrder
                })
                .ToListAsync();
        }

        public async Task<AdminOptionDetailDto> GetByIdAsync(Guid optionId)
        {
            var option = await _context.QuizQuestionOptions
                .FirstOrDefaultAsync(x => x.OptionId == optionId);

            if (option == null)
                throw new KeyNotFoundException("Option not found.");

            return MapToDetailDto(option);
        }

        public async Task<AdminOptionDetailDto> CreateAsync(Guid questionId, CreateOptionRequest request)
        {
            var questionExists = await _context.QuizQuestions
                .AnyAsync(x => x.QuestionId == questionId);

            if (!questionExists)
                throw new KeyNotFoundException("Question not found.");

            var normalizedText = request.OptionText.Trim();

            var duplicatedOrder = await _context.QuizQuestionOptions
                .AnyAsync(x => x.QuestionId == questionId && x.DisplayOrder == request.DisplayOrder);

            if (duplicatedOrder)
                throw new InvalidOperationException("DisplayOrder already exists in this question.");

            if (request.IsCorrect)
            {
                var hasCorrect = await _context.QuizQuestionOptions
                    .AnyAsync(x => x.QuestionId == questionId && x.IsCorrect);

                if (hasCorrect)
                    throw new InvalidOperationException("This question already has a correct option.");
            }

            var option = new E_Learning.Entity.QuizQuestionOption
            {
                OptionId = Guid.NewGuid(),
                QuestionId = questionId,
                OptionText = normalizedText,
                IsCorrect = request.IsCorrect,
                DisplayOrder = request.DisplayOrder
            };

            _context.QuizQuestionOptions.Add(option);
            await _context.SaveChangesAsync();

            return MapToDetailDto(option);
        }

        public async Task<AdminOptionDetailDto> UpdateAsync(Guid optionId, UpdateOptionRequest request)
        {
            var option = await _context.QuizQuestionOptions
                .FirstOrDefaultAsync(x => x.OptionId == optionId);

            if (option == null)
                throw new KeyNotFoundException("Option not found.");

            var normalizedText = request.OptionText.Trim();

            var duplicatedOrder = await _context.QuizQuestionOptions
                .AnyAsync(x => x.OptionId != optionId
                            && x.QuestionId == option.QuestionId
                            && x.DisplayOrder == request.DisplayOrder);

            if (duplicatedOrder)
                throw new InvalidOperationException("DisplayOrder already exists in this question.");

            if (request.IsCorrect)
            {
                var anotherCorrect = await _context.QuizQuestionOptions
                    .AnyAsync(x => x.OptionId != optionId
                                && x.QuestionId == option.QuestionId
                                && x.IsCorrect);

                if (anotherCorrect)
                    throw new InvalidOperationException("This question already has another correct option.");
            }

            option.OptionText = normalizedText;
            option.IsCorrect = request.IsCorrect;
            option.DisplayOrder = request.DisplayOrder;

            await _context.SaveChangesAsync();

            return MapToDetailDto(option);
        }

        public async Task DeleteAsync(Guid optionId)
        {
            var option = await _context.QuizQuestionOptions
                .FirstOrDefaultAsync(x => x.OptionId == optionId);

            if (option == null)
                throw new KeyNotFoundException("Option not found.");

            var usedInAnswers = await _context.QuizAttemptAnswers
                .AnyAsync(x => x.SelectedOptionId == optionId);

            if (usedInAnswers)
                throw new InvalidOperationException("Cannot delete option because quiz answers already exist.");

            _context.QuizQuestionOptions.Remove(option);
            await _context.SaveChangesAsync();
        }

        private static AdminOptionDetailDto MapToDetailDto(E_Learning.Entity.QuizQuestionOption option)
        {
            return new AdminOptionDetailDto
            {
                OptionId = option.OptionId,
                QuestionId = option.QuestionId,
                OptionText = option.OptionText,
                IsCorrect = option.IsCorrect,
                DisplayOrder = option.DisplayOrder
            };
        }
    }
}